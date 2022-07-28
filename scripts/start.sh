#!/bin/bash

set -e

if [ -z "$ENTRYPOINT" ]; then
    ENTRYPOINT="/usr/local/bin/docker-entrypoint.sh"
fi

if [ "$HOSTNAME" = "mariadb-0" ]; then 
    bash -c "$ENTRYPOINT mariadbd --wsrep-new-cluster"
else
    bash -c "$ENTRYPOINT mariadbd"
fi