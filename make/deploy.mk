##@ Deploy

KIND_CONFIG ?= $(ROOT_DIR)/hack/config/kind.yaml
KIND_IMAGE ?= kindest/node:v1.28.0
CLUSTER ?= poc
DOCKER_CONFIG ?= $(HOME)/.docker/config.json 

.PHONY: cluster
cluster: kind ## Create a single node kind cluster.
	$(KIND) create cluster --name $(CLUSTER) --image $(KIND_IMAGE)

.PHONY: cluster-ha
cluster-ha: kind ## Create a HA kind cluster.
	$(KIND) create cluster --name $(CLUSTER) --config $(KIND_CONFIG)

.PHONY: cluster-delete
cluster-delete: kind ## Delete the kind cluster.
	$(KIND) delete cluster --name $(CLUSTER)

.PHONY: kubectl cluster-ctx
cluster-ctx: ## Sets cluster context.
	$(KUBECTL) config use-context kind-$(CLUSTER)

.PHONY: cluster-nodes
cluster-nodes: kind ## Get cluster nodes.
	@$(KIND) get nodes --name $(CLUSTER)

.PHONY: registry
registry: ## Configure registry auth.
	@for node in $$(make -s cluster-nodes); do \
		docker cp $(DOCKER_CONFIG) $$node:/var/lib/kubelet/config.json; \
	done

.PHONY: install-prometheus
install-prometheus: cluster-ctx ## Install kube-prometheus-stack helm chart.
	@$(ROOT_DIR)/hack/install_prometheus.sh

CERT_MANAGER_VERSION ?= "v1.9.1"
.PHONY: install-cert-manager
install-cert-manager: cluster-ctx ## Install cert-manager helm chart.
	@CERT_MANAGER_VERSION=$(CERT_MANAGER_VERSION) $(ROOT_DIR)/hack/install_cert_manager.sh

METALLB_VERSION ?= "0.13.9"
.PHONY: install-metallb
install-metallb: cluster-ctx ## Install metallb helm chart.
	@METALLB_VERSION=$(METALLB_VERSION) $(ROOT_DIR)/hack/install_metallb.sh

MARIADB_OPERATOR_VERSION ?= "0.24.0"
.PHONY: install-mariadb-operator
install-mariadb-operator: cluster-ctx ## Installs mariadb-operator.
	@MARIADB_OPERATOR_VERSION=$(MARIADB_OPERATOR_VERSION) $(ROOT_DIR)/hack/install_mariadb_operator.sh

.PHONY: downscale-mariadb-operator
downscale-mariadb-operator: ## Downscale mariadb-operator to avoid clashing with its failover mechanism.
	$(KUBECTL) scale deployment mariadb-operator -n mariadb-operator --replicas=0

.PHONY: upscale-mariadb-operator
upscale-mariadb-operator: ## Upscale back mariadb-operator.
	$(KUBECTL) scale deployment mariadb-operator -n mariadb-operator --replicas=1

.PHONY: install
install: cluster-ctx install-prometheus install-cert-manager install-mariadb-operator ## Install dependencies.

##@ Deploy - MariaDB

.PHONY: mariadb-config
mariadb-config: ## Install MariaDB configuration.
	$(KUBECTL) apply -f $(ROOT_DIR)/hack/manifests/mariadb/config

.PHONY: mariadb
mariadb: mariadb-config ## Install MariaDB.
	$(KUBECTL) apply -f $(ROOT_DIR)/hack/manifests/mariadb/mariadb.yaml

.PHONY: mariadb-repl
mariadb-repl: mariadb-config ## Install MariaDB with asynchronous replication.
	$(KUBECTL) apply -f $(ROOT_DIR)/hack/manifests/mariadb/mariadb_repl.yaml

.PHONY: mariadb-repl-min
mariadb-repl-min: mariadb-config ## Install a minimal version of MariaDB with asynchronous replication.
	$(KUBECTL) apply -f $(ROOT_DIR)/hack/manifests/mariadb/mariadb_repl_min.yaml

POD ?= mariadb-repl-0
.PHONY: delete-pod
delete-pod: downscale-mariadb-operator ## Continiously delete a Pod.
	@while true; do kubectl delete pod $(POD); sleep 1; done;

##@ Deploy - sysbench

.PHONY: sysbench-prepare
sysbench-prepare: ## Prepare sysbench tests.
	$(KUBECTL) apply -f $(ROOT_DIR)/hack/manifests/sysbench/sysbench-prepare_job.yaml

.PHONY: sysbench
sysbench: ## Run sysbench tests.
	$(KUBECTL) apply -f $(ROOT_DIR)/hack/manifests/sysbench/sysbench_cronjob.yaml
	$(KUBECTL) create job sysbench --from cronjob/sysbench