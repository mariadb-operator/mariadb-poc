##@ Networking

CIDR_PREFIX_PATH ?= /tmp/cidr-prefix.txt
CIDR_PREFIX_CODE := $(shell go run $(ROOT_DIR)/hack/get_kind_cidr_prefix.go > $(CIDR_PREFIX_PATH); echo $$?)
CIDR_PREFIX ?= ""
ifeq ($(CIDR_PREFIX_CODE),0)
	CIDR_PREFIX = $(shell cat $(CIDR_PREFIX_PATH))
else
  $(error Error getting CIDR prefix: $(shell cat $(CIDR_PREFIX_PATH)))
endif

.PHONY: cidr
cidr: ## Get CIDR used by KIND.
	@echo "$(CIDR_PREFIX).0.0/16"

.PHONY: host-mariadb
host-mariadb:  ## Add mariadb hosts to /etc/hosts.
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.10 mariadb-0.mariadb-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.11 mariadb-1.mariadb-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.12 mariadb-2.mariadb-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.13 mariadb-3.mariadb-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.20 mariadb.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.30 mariadb-primary.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.31 mariadb-secondary.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.40 mariadb.mariadb.svc.cluster.local

.PHONY: host-mariadb-test
host-mariadb-test: ## Add mariadb test hosts to /etc/hosts.
	@$(ROOT_DIR)/hack/add_host.sh ${CIDR_PREFIX}.0.100 mariadb-test.default.svc.cluster.local

.PHONY: host-mariadb-repl
host-mariadb-repl: ## Add mariadb repl hosts to /etc/hosts.
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.110 mariadb-repl-0.mariadb-repl-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.111 mariadb-repl-1.mariadb-repl-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.112 mariadb-repl-2.mariadb-repl-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.113 mariadb-repl-3.mariadb-repl-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.120 mariadb-repl.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.130 mariadb-repl-primary.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.131 mariadb-repl-secondary.default.svc.cluster.local

.PHONY: host-mariadb-galera
host-mariadb-galera: ## Add mariadb galera hosts to /etc/hosts.
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.140 mariadb-galera-0.mariadb-galera-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.141 mariadb-galera-1.mariadb-galera-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.142 mariadb-galera-2.mariadb-galera-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.143 mariadb-galera-3.mariadb-galera-internal.default.svc.cluster.local	
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.150 mariadb-galera.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.160 mariadb-galera-primary.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.161 mariadb-galera-secondary.default.svc.cluster.local

.PHONY: host-maxscale
host-maxscale: ## Add maxscale hosts to /etc/hosts.
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.210 maxscale-0.maxscale-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.211 maxscale-1.maxscale-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.212 maxscale-2.maxscale-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.213 maxscale-3.maxscale-internal.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.210 maxscale-conn.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.214 maxscale.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.221 maxscale-rw-split.default.svc.cluster.local
	@$(ROOT_DIR)/hack/add_host.sh $(CIDR_PREFIX).0.222 maxscale-api.default.svc.cluster.local

.PHONY: net
net: install-metallb host-mariadb host-mariadb-test host-mariadb-repl host-mariadb-galera host-maxscale ## Configure networking for local development.