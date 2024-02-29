#!/bin/bash

kubectl create configmap entrypoint \
  --from-file entrypoint.sh \
  --dry-run=client -o yaml > entrypoint.yaml
kubectl apply -f entrypoint.yaml