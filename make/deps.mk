##@ Dependencies

KIND ?= $(LOCALBIN)/kind
KUBECTL ?= $(LOCALBIN)/kubectl

KIND_VERSION ?= v0.20.0
KUBECTL_VERSION ?= v1.28.0

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

kind: $(KIND) ## Download kind locally if necessary.
$(KIND): $(LOCALBIN)
	GOBIN=$(LOCALBIN) go install sigs.k8s.io/kind@$(KIND_VERSION)

kubectl: ## Download kubectl locally if necessary.
ifeq (,$(wildcard $(KUBECTL)))
ifeq (,$(shell which kubectl 2>/dev/null))
	@{ \
	set -e ;\
	mkdir -p $(dir $(KUBECTL)) ;\
	OS=$(shell go env GOOS) && ARCH=$(shell go env GOARCH) && \
	curl -sSLo $(KUBECTL) https://dl.k8s.io/release/$(KUBECTL_VERSION)/bin/linux/$${ARCH}/kubectl ;\
	chmod +x $(KUBECTL) ;\
	}
else
KUBECTL = $(shell which kubectl)
endif
endif