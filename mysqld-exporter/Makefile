ROOT_DIR ?= $(shell pwd)/..

##@ mysqld-exporter PoC

.PHONY: monitoring-user
monitoring-user:  ## Configure monitoring user.
	$(KUBECTL) apply -f ./manifests/monitoring_user.yaml
	$(KUBECTL) apply -f ./manifests/monitoring_grant.yaml

.PHONY: exporter
exporter:  ## Configure exporter.
	$(KUBECTL) create secret generic config --from-file=config/exporter.cnf --dry-run=client -o yaml | $(KUBECTL) apply -f -
	$(KUBECTL) apply -f ./manifests/exporter_deployment.yaml

include ../make/base.mk
include ../make/deploy.mk
include ../make/deps.mk
include ../make/net.mk