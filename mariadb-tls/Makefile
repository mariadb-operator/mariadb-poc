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

##@ MariaDB TLS PoC

.PHONY: deploy
deploy: pki kubectl # Deploy Poc.
	$(KUBECTL) apply -f manifests/

include ../make/base.mk
include ../make/deploy.mk
include ../make/deps.mk
include ../make/net.mk
include ../make/pki.mk