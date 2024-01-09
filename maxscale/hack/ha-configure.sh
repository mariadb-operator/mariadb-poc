#!/bin/bash

set -eo pipefail

CURDIR="$( dirname "${BASH_SOURCE[0]}" )"
source "$CURDIR/lib.sh"

echo "Configuring MaxScale instance: ${MAXSCALE_API_URL}"

echo "Configuring mariadb-operator user"
configure_admin

echo "Creating servers"
post v1/servers "$AUTH_HEADER" mariadb-0.json
post v1/servers "$AUTH_HEADER" mariadb-1.json
post v1/servers "$AUTH_HEADER" mariadb-2.json

echo "Creating monitor"
post v1/monitors "$AUTH_HEADER" replication-monitor.json

echo "Creating service"
post v1/services "$AUTH_HEADER" splitter-service.json

echo "Creating listener"
post v1/listeners "$AUTH_HEADER" splitter-listener.json