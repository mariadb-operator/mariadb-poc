##@ PKI

PKI_DIR ?= /tmp/pki

CA_CERT ?= $(PKI_DIR)/ca.crt
CA_KEY ?= $(PKI_DIR)/ca.key
CA_NAME ?= mariadb
.PHONY: ca
ca: ## Generates CA private key and certificate.
	@if [ ! -f "$(CA_CERT)" ] || [ ! -f "$(CA_KEY)" ]; then \
		mkdir -p $(PKI_DIR); \
		openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
			-subj "/CN=$(CA_NAME)" -out $(CA_CERT) -keyout $(CA_KEY); \
	else \
		echo "CA files already exist, skipping generation."; \
	fi

CERT_SUBJECT ?= "/CN=localhost"
CERT_ALT_NAMES ?= "subjectAltName=DNS:localhost,IP:127.0.0.1"
CERT ?= $(PKI_DIR)/tls.crt 
KEY ?= $(PKI_DIR)/tls.key 
.PHONY: cert
cert: ## Generates certificate keypair.
	@mkdir -p $(PKI_DIR)
	@openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
		-subj $(CERT_SUBJECT) -addext $(CERT_ALT_NAMES) \
		-out $(CERT) -keyout $(KEY) \
		-CA $(CA_CERT) -CAkey $(CA_KEY)

.PHONY: ca-server
ca-server: ## Generates CA private key and certificate for server.
	CA_CERT=$(PKI_DIR)/server-ca.crt CA_KEY=$(PKI_DIR)/server-ca.key CA_NAME=server-ca $(MAKE) ca

.PHONY: cert-server
cert-server: ca-server ## Generates certificate keypair for server.
	CA_CERT=$(PKI_DIR)/server-ca.crt CA_KEY=$(PKI_DIR)/server-ca.key \
	CERT=$(PKI_DIR)/server.crt KEY=$(PKI_DIR)/server.key \
	CERT_SUBJECT="/CN=mariadb.svc.cluster.local" CERT_ALT_NAMES="subjectAltName=DNS:mariadb.svc,DNS:mariadb" \
	$(MAKE) cert

.PHONY: ca-client
ca-client: ## Generates CA private key and certificate for client.
	CA_CERT=$(PKI_DIR)/client-ca.crt CA_KEY=$(PKI_DIR)/client-ca.key CA_NAME=client-ca $(MAKE) ca

.PHONY: cert-client
cert-client: ca-client ## Generates certificate keypair for client.
	CA_CERT=$(PKI_DIR)/client-ca.crt CA_KEY=$(PKI_DIR)/client-ca.key \
	CERT=$(PKI_DIR)/client.crt KEY=$(PKI_DIR)/client.key \
	CERT_SUBJECT="/CN=client" CERT_ALT_NAMES="subjectAltName=DNS:client" \
	$(MAKE) cert

.PHONY: pki
pki: cert-client cert-server ## Generates PKI Secret.
	@$(ROOT_DIR)/hack/pki_secret.sh