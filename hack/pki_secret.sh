#!/bin/bash

CAS=(
  "server"
  "client"
)
for CA in "${CAS[@]}"; do
 kubectl create secret tls $CA-ca \
    --cert=/tmp/pki/ca/$CA.crt \
    --key=/tmp/pki/ca/$CA.key \
    --dry-run=client -o yaml | kubectl apply -f -
done

PKIS=(
  "server"
  "client"
)
for PKI in "${PKIS[@]}"; do
 kubectl create secret tls $PKI \
    --cert=/tmp/pki/$PKI.crt \
    --key=/tmp/pki/$PKI.key \
    --dry-run=client -o yaml | kubectl apply -f -
done