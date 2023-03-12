
# Get the currently used golang install path (in GOPATH/bin, unless GOBIN is set)
ifeq (,$(shell go env GOBIN))
GOBIN=$(shell go env GOPATH)/bin
else
GOBIN=$(shell go env GOBIN)
endif

.PHONY: all
all: help

##@ General

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Cluster

KIND_IMAGE ?= kindest/node:v1.26.0
CLUSTER ?= mdb-poc

.PHONY: cluster
cluster: kind ## Create the kind cluster.
	$(KIND) create cluster --name $(CLUSTER) --image $(KIND_IMAGE)

.PHONY: cluster-delete
cluster-delete: kind ## Delete the kind cluster.
	$(KIND) delete cluster --name $(CLUSTER)

.PHONY: cluster-ctx
cluster-ctx: ## Sets cluster context.
	@kubectl config use-context kind-$(CLUSTER)

##@ Tooling
KIND ?= $(LOCALBIN)/kind
KIND_VERSION ?= v0.17.0

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

kind: $(KIND) ## Download kind locally if necessary.
$(KIND): $(LOCALBIN)
	GOBIN=$(LOCALBIN) go install sigs.k8s.io/kind@$(KIND_VERSION)