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

.PHONY: maxscale-user
maxscale-user: cluster-ctx ## Configure maxscale user.
	$(KUBECTL) apply -f ./manifests/maxscale_user.yaml
	$(KUBECTL) apply -f ./manifests/maxscale_grant.yaml

.PHONY: client-user
client-user: cluster-ctx ## Configure client user.
	$(KUBECTL) apply -f ./manifests/client_user.yaml
	$(KUBECTL) apply -f ./manifests/client_grant.yaml

.PHONY: monitor-user
monitor-user: cluster-ctx ## Configure monitor user.
	$(KUBECTL) apply -f ./manifests/monitor_user.yaml
	$(KUBECTL) apply -f ./manifests/monitor_grant.yaml

.PHONY: users
users: maxscale-user client-user monitor-user ## Configure users

.PHONY: conn-router-config 
conn-router-config: cluster-ctx ## Create connection router configuration.
	$(KUBECTL) create secret generic conn-router-config \
		--from-file=config/0-maxscale.cnf \
		--from-file=config/1-servers.cnf \
		--from-file=config/2-conn-router.cnf \
		--dry-run=client -o yaml | $(KUBECTL) apply -f -

.PHONY: rw-split-config
rw-split-config: cluster-ctx ## Create read-write split router configuration.
	$(KUBECTL) create secret generic rw-split-config \
		--from-file=config/0-maxscale.cnf \
		--from-file=config/1-servers.cnf \
		--from-file=config/2-rw-split-router.cnf \
		--dry-run=client -o yaml | $(KUBECTL) apply -f -

.PHONY: config
config: conn-router-config rw-split-config

include ../make/base.mk
include ../make/deploy.mk
include ../make/deps.mk
include ../make/net.mk