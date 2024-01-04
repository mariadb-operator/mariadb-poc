#!/bin/bash

set -eo pipefail

if [ -z "$MAXSCALE_API_URL" ]; then
  MAXSCALE_API_URL="http://maxscale-api.default.svc.cluster.local:8989"
fi
CURDIR="$( dirname "${BASH_SOURCE[0]}" )"
PAYLOADS_DIR="$CURDIR/payloads"
DEFAULT_AUTH_HEADER="Authorization: Basic $(printf "admin:mariadb" | base64)" 
AUTH_HEADER="Authorization: Basic $(printf "mariadb-operator:mariadb" | base64)"

function post() {
  REQUEST_PATH=$1
  REQUEST_AUTH_HEADER=$2
  if [ -z "$REQUEST_PATH" ]; then
    echo "REQUEST_PATH must be set"
    exit 1
  fi
  if [ -z "$REQUEST_AUTH_HEADER" ]; then
    echo "AUTH_HEADER must be set"
    exit 1
  fi
  BODY_FILE=$3

  URL="$MAXSCALE_API_URL/$REQUEST_PATH"
  if [ -z $BODY_FILE ]; then
    curl -X POST --header 'Content-Type: application/json' --header "$REQUEST_AUTH_HEADER" --location "$URL"
  else
    BODY="$PAYLOADS_DIR/$BODY_FILE"
    curl -X POST -d @$BODY --header 'Content-Type: application/json' --header "$REQUEST_AUTH_HEADER" --location "$URL"
  fi
}

function delete() {
  REQUEST_PATH=$1
  REQUEST_AUTH_HEADER=$2
  if [ -z "$REQUEST_PATH" ]; then
    echo "REQUEST_PATH must be set"
    exit 1
  fi
  if [ -z "$REQUEST_AUTH_HEADER" ]; then
    echo "REQUEST_AUTH_HEADER must be set"
    exit 1
  fi

  URL="$MAXSCALE_API_URL/$REQUEST_PATH"
  curl -X DELETE --header "$REQUEST_AUTH_HEADER" --location "$URL"
}

function configure_admin() {
  echo "Creating mariadb-operator user"
  post "/v1/users/inet" "$DEFAULT_AUTH_HEADER" "mariadb-operator.json" 

  echo "Deleting default admin user"
  delete "v1/users/inet/admin" "$AUTH_HEADER"
}