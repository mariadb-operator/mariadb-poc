#!/bin/bash

kubectl create secret generic mariadb-scripts --from-file=run.sh --dry-run=client -o yaml > secret.yaml
kubectl apply -f secret.yaml