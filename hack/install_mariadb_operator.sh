#!/bin/bash

set -eo pipefail

CONFIG="$( dirname "${BASH_SOURCE[0]}" )"/config
if [ -z "$MARIADB_OPERATOR_VERSION" ]; then 
  MARIADB_OPERATOR_VERSION="0.24.0"
fi

helm repo add mariadb-operator https://mariadb-operator.github.io/mariadb-operator
helm repo update mariadb-operator

helm upgrade --install \
  --version $MARIADB_OPERATOR_VERSION \
  -n mariadb-operator --create-namespace \
  -f $CONFIG/mariadb-operator.yaml \
  mariadb-operator mariadb-operator/mariadb-operator