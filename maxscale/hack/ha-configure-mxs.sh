#!/bin/bash

set -eo pipefail

CURDIR="$( dirname "${BASH_SOURCE[0]}" )"
source "$CURDIR/lib.sh"

echo "Patching MaxScale instance: ${MAXSCALE_API_URL}"
patch v1/maxscale "$AUTH_HEADER" maxscale.json