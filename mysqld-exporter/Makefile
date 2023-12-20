ROOT_DIR ?= $(shell pwd)/..

##@ mysqld-exporter PoC

.PHONY: monitoring-user
monitoring-user: cluster-ctx ## Configure monitoring user.
	$(KUBECTL) apply -f ./manifests/monitoring_user.yaml
	$(KUBECTL) apply -f ./manifests/monitoring_grant.yaml

.PHONY: exporter
exporter: cluster-ctx ## Configure exporter.
	$(KUBECTL) create secret generic config --from-file=config/exporter.cnf --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(KUBECTL) apply -f ./manifests/exporter_deployment.yaml
	$(KUBECTL) apply -f ./manifests/exporter_service.yaml

.PHONY: servicemonitor
servicemonitor: cluster-ctx ## Configure ServiceMonitor.
	$(KUBECTL) apply -f ./manifests/mariadb_repl_servicemonitor.yaml

include ../make/base.mk
include ../make/deploy.mk
include ../make/deps.mk
include ../make/net.mk