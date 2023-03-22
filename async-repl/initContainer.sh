#!/bin/bash

set -ex
echo 'Starting init-mariadb';
ls /mnt/repl

[[ $HOSTNAME =~ -([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[1]}

if [[ $ordinal -eq 0 ]]; then
  cp /mnt/repl/primary.cnf /etc/mysql/conf.d/server-id.cnf
  cp /mnt/repl/primary.sql /docker-entrypoint-initdb.d
else
  cp /mnt/repl/replica.cnf /etc/mysql/conf.d/server-id.cnf
  cp /mnt/repl/replica.sql /docker-entrypoint-initdb.d
fi

echo server-id=$((1000 + $ordinal)) >> /etc/mysql/conf.d/server-id.cnf
ls /etc/mysql/conf.d/
cat /etc/mysql/conf.d/server-id.cnf