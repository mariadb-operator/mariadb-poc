#!/bin/bash

kubectl create secret generic mariadb-repl \
  --from-file initContainer.sh \
  --dry-run=client -o yaml > mariadb-repl-secret.yaml
kubectl apply -f mariadb-repl-secret.yaml