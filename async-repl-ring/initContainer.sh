#!/bin/bash

set -ex
echo 'Starting init-mariadb';
ls /mnt/repl

[[ `hostname` =~ -([0-9]+)$ ]] || exit 1
ordinal=${BASH_REMATCH[1]}

if [[ $ordinal -eq 0 ]]; then
  cat <<EOF | tee /tmp/repl.sql
CREATE USER IF NOT EXISTS 'repluser'@'%' IDENTIFIED BY 'replsecret';
GRANT REPLICATION REPLICA ON *.* TO 'repluser'@'%';

CHANGE MASTER TO 
MASTER_HOST='mariadb-2.mariadb.default.svc.cluster.local',
MASTER_USER='repluser',
MASTER_PASSWORD='replsecret',
MASTER_CONNECT_RETRY=10;
EOF
elif [[ $ordinal -eq 1 ]]; then
  cat <<EOF | tee /tmp/repl.sql
CREATE USER IF NOT EXISTS 'repluser'@'%' IDENTIFIED BY 'replsecret';
GRANT REPLICATION REPLICA ON *.* TO 'repluser'@'%';

CHANGE MASTER TO 
MASTER_HOST='mariadb-0.mariadb.default.svc.cluster.local',
MASTER_USER='repluser',
MASTER_PASSWORD='replsecret',
MASTER_CONNECT_RETRY=10;
EOF
elif [[ $ordinal -eq 2 ]]; then
  cat <<EOF | tee /tmp/repl.sql
CREATE USER IF NOT EXISTS 'repluser'@'%' IDENTIFIED BY 'replsecret';
GRANT REPLICATION REPLICA ON *.* TO 'repluser'@'%';

CHANGE MASTER TO 
MASTER_HOST='mariadb-1.mariadb.default.svc.cluster.local',
MASTER_USER='repluser',
MASTER_PASSWORD='replsecret',
MASTER_CONNECT_RETRY=10;
EOF
fi

cat <<EOF | tee /tmp/repl.cnf
[mariadb]
log-bin
log-basename=mariadb
rpl_semi_sync_master_enabled=ON
rpl_semi_sync_master_timeout=30000
rpl_semi_sync_master_wait_point=AFTER_SYNC
rpl_semi_sync_slave_enabled=ON
server-id=$((1000 + $ordinal))
EOF

cp /tmp/repl.cnf /etc/mysql/conf.d/server-id.cnf
cp /tmp/repl.sql /docker-entrypoint-initdb.d

ls /etc/mysql/conf.d/
cat /etc/mysql/conf.d/server-id.cnf