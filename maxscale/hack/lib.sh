#!/bin/bash

set -eo pipefail

if [ -z "$MAXSCALE_API_URL" ]; then
  MAXSCALE_API_URL="http://maxscale-api.default.svc.cluster.local:8989"
fi
CURDIR="$( dirname "${BASH_SOURCE[0]}" )"
PAYLOADS_DIR="$CURDIR/payloads"
AUTH_HEADER="Authorization: Basic $(printf "admin:mariadb" | base64)"

function post() {
  REQUEST_PATH=$1
  BODY_FILE=$2
  
  URL="$MAXSCALE_API_URL/$REQUEST_PATH"
  if [ -z $BODY_FILE ]; then
    curl -X POST --header 'Content-Type: application/json' --header "$AUTH_HEADER" --location $URL
  else
    BODY="$PAYLOADS_DIR/$BODY_FILE"
    curl -X POST -d @$BODY --header 'Content-Type: application/json' --header "$AUTH_HEADER" --location $URL
  fi
}