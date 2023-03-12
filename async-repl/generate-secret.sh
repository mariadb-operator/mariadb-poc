#!/bin/bash

kubectl create secret generic mariadb-repl \
  --from-file initContainer.sh \
  --from-file primary.cnf --from-file primary.sql \
  --from-file replica.cnf --from-file replica.sql \
  --dry-run=client -o yaml > mariadb-repl-secret.yaml
kubectl apply -f mariadb-repl-secret.yaml