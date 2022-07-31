#!/bin/bash

kubectl create secret generic mariadb-scripts --from-file=run.sh --from-file=lib.sh --dry-run=client -o yaml > secret.yaml
kubectl apply -f secret.yaml