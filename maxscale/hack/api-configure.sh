#!/bin/bash

set -eo pipefail

if [ -z "$MAXSCALE_API_URL" ]; then
  MAXSCALE_API_URL="http://maxscale-api.default.svc.cluster.local:8989"
fi
PAYLOADS_DIR="$( dirname "${BASH_SOURCE[0]}" )"/payloads
AUTH_HEADER="Authorization: Basic $(printf "admin:mariadb" | base64)"

function post() {
  REQUEST_PATH=$1
  BODY_FILE=$2
  
  BODY="$PAYLOADS_DIR/$BODY_FILE"
  URL="$MAXSCALE_API_URL/$REQUEST_PATH"
  curl -X POST -d @$BODY --header 'Content-Type: application/json' --header "$AUTH_HEADER" --location $URL
}

echo "Creating servers"
post v1/servers mariadb-0.json
post v1/servers mariadb-1.json
post v1/servers mariadb-2.json

echo "Creating monitor"
post v1/monitors replication-monitor.json

echo "Creating service"
post v1/services splitter-service.json

echo "Creating listener"
post v1/listeners splitter-listener.json

