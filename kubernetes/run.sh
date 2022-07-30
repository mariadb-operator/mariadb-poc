#!/bin/bash

set -e

if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "Environment variable 'MARIADB_ROOT_PASSWORD' must be set."
    exit 1
fi

HOSTNAME=$(hostname)
STATEFULSET_INDEX=${HOSTNAME##*-}
GALERA_CONFIG_FILE=/etc/mysql/mariadb.conf.d/galera.cnf
GALERA_STATE_FILE=/var/lib/mysql/grastate.dat

if [ -z "$ENTRYPOINT" ]; then 
    ENTRYPOINT="/usr/local/bin/docker-entrypoint.sh"
fi

WSREP_NEW_CLUSTER="OFF"
if [ "$STATEFULSET_INDEX" = "0" ] && [ -z "$(ls -A /var/lib/mysql)"  ]; then
    WSREP_NEW_CLUSTER="ON"
fi
if [ "$BOOSTRAP_CLUSTER" ]; then
    WSREP_NEW_CLUSTER="ON"
fi

if [ -z "$SAFE_TO_BOOTSTRAP" ]; then 
    SAFE_TO_BOOTSTRAP=true
fi

# MariaDB Galera config file
cat <<EOF | tee ${GALERA_CONFIG_FILE} 
[mysqld]
bind-address=0.0.0.0
default_storage_engine=InnoDB
binlog_format=row
innodb_autoinc_lock_mode=2

# Cluster configuration: https://galeracluster.com/library/documentation/mysql-wsrep-options.html
wsrep_new_cluster="$WSREP_NEW_CLUSTER"
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_address="gcomm://mariadb-0.mariadb-headless.default.svc.cluster.local,mariadb-1.mariadb-headless.default.svc.cluster.local,mariadb-2.mariadb-headless.default.svc.cluster.local"
wsrep_cluster_name=galera
wsrep_slave_threads=4

# Node configuration
wsrep_node_address="$HOSTNAME.mariadb-headless.default.svc.cluster.local"
wsrep_node_name="$HOSTNAME"

# SST: https://mariadb.com/kb/en/introduction-to-state-snapshot-transfers-ssts/ 
wsrep_sst_method="mariabackup"
wsrep_sst_auth="root:$MARIADB_ROOT_PASSWORD"
# wsrep_sst_method="rsync"
EOF

if [ "$SAFE_TO_BOOTSTRAP" ] && [ -f "$GALERA_STATE_FILE" ]; then 
    sed -i  "s/safe_to_bootstrap: 0/safe_to_bootstrap: 1/" "$GALERA_STATE_FILE" 
fi

bash -c "$ENTRYPOINT mariadbd"