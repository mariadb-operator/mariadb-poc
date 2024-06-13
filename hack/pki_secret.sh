#!/bin/bash

PKIS=(
  "server-ca"
  "server"
  "client-ca"
  "client"
)
for PKI in "${PKIS[@]}"; do
 kubectl create secret tls $PKI \
    --cert=/tmp/pki/$PKI.crt \
    --key=/tmp/pki/$PKI.key \
    --dry-run=client -o yaml | kubectl apply -f -
done