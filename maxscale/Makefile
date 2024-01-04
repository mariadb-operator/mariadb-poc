# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

ifndef ignore-not-found
  ignore-not-found = false
endif

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

ROOT_DIR ?= $(shell pwd)/..
CLUSTER ?= mxs

##@ MaxScale PoC

.PHONY: auth
auth: # Create auth.
	$(KUBECTL) apply -f manifests/auth

.PHONY: config
config: ## Create config Secret
	$(KUBECTL) create secret generic config \
		--from-file=config/conn.cnf \
		--from-file=config/rw-split.cnf \
		--from-file=config/api.cnf \
		--dry-run=client -o yaml | $(KUBECTL) apply -f -

.PHONY: conn
conn: config ## Deploy connection PoC.
	$(KUBECTL) apply -f manifests/conn

.PHONY: rw-split
rw-split: config ## Deploy rw-split PoC.
	$(KUBECTL) apply -f manifests/rw-split

MAXSCALE_API_URL ?= http://maxscale-api.default.svc.cluster.local:8989
.PHONY: api
api: config ## Deploy api PoC.
	$(KUBECTL) apply -f manifests/api
	$(KUBECTL) wait --for=condition=available deployment maxscale-api
	@MAXSCALE_API_URL=$(MAXSCALE_API_URL) ./hack/api-configure.sh

COMMAND_PATH ?= v1/maxscale/modules/mariadbmon/switchover?replication-monitor&mariadb-1&mariadb-0
.PHONY: command
command: ## Execute a command in MaxScale
	@MAXSCALE_API_URL="$(MAXSCALE_API_URL)" COMMAND_PATH="$(COMMAND_PATH)" ./hack/command.sh

FAILOVER_COMMAND_PATH ?= "v1/maxscale/modules/mariadbmon/failover?replication-monitor"
.PHONY: failover
failover: ## Execute a manual failover in MaxScale
	@MAXSCALE_API_URL=$(MAXSCALE_API_URL) COMMAND_PATH=$(FAILOVER_COMMAND_PATH) $(MAKE) command

SWITCHOVER_COMMAND_PATH ?= "v1/maxscale/modules/mariadbmon/switchover?replication-monitor&mariadb-1&mariadb-0"
.PHONY: switchover
switchover: ## Execute a manual switchover in MaxScale
	@MAXSCALE_API_URL=$(MAXSCALE_API_URL) COMMAND_PATH=$(SWITCHOVER_COMMAND_PATH) $(MAKE) command

##@ MaxScale PoC - cleanup

.PHONY: config-delete
config-delete: ## Delete config Secret
	$(KUBECTL) delete secret config

.PHONY: auth
auth-delete: # Delete auth.
	$(KUBECTL) delete -f manifests/auth

.PHONY: conn-delete
conn-delete: ## Undeploy connection PoC.
	$(KUBECTL) delete -f manifests/conn

.PHONY: rw-split-delete
rw-split-delete: ## Undeploy rw-split PoC.
	$(KUBECTL) delete -f manifests/rw-split

.PHONY: api-delete
api-delete: ## Undeploy rw-split PoC.
	$(KUBECTL) delete -f manifests/api

include ../make/base.mk
include ../make/deploy.mk
include ../make/deps.mk
include ../make/net.mk