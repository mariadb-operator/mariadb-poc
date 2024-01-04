#!/bin/bash

set -eo pipefail

CURDIR="$( dirname "${BASH_SOURCE[0]}" )"
source "$CURDIR/lib.sh"

if [ -z "$COMMAND_PATH" ]; then
  echo "'COMMAND_PATH' environment variable must be present"
  exit 1
fi

echo "Executing command: $COMMAND_PATH"
post "$COMMAND_PATH"
