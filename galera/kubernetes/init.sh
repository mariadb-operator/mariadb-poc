#!/bin/bash

set -e

if [ -z "$MARIADB_ROOT_PASSWORD" ]; then
    echo "Environment variable 'MARIADB_ROOT_PASSWORD' must be set."
    exit 1
fi

CURRENT_DIR="$( dirname "${BASH_SOURCE[0]}" )"

source "$CURRENT_DIR/lib.sh"

GALERA_CONFIG_DIR=/etc/mysql/mariadb.conf.d
GALERA_CONFIG_FILE="$GALERA_CONFIG_DIR/0-galera.cnf"
GALERA_STATE_FILE=/var/lib/mysql/grastate.dat

if [ -z "$SAFE_TO_BOOTSTRAP" ]; then 
    SAFE_TO_BOOTSTRAP=true
fi

# MariaDB Galera config file
mkdir -p $GALERA_CONFIG_DIR
cat <<EOF | tee ${GALERA_CONFIG_FILE} 
[mysqld]
bind-address=0.0.0.0
default_storage_engine=InnoDB
binlog_format=row
innodb_autoinc_lock_mode=2

# Cluster configuration: https://galeracluster.com/library/documentation/mysql-wsrep-options.html
wsrep_on=ON
wsrep_provider=/usr/lib/galera/libgalera_smm.so
wsrep_cluster_address="$(get_cluster_address)"
wsrep_cluster_name=galera
wsrep_slave_threads=4

# Node configuration
wsrep_node_address="$HOSTNAME.mariadb-headless.default.svc.cluster.local"
wsrep_node_name="$HOSTNAME"

# SST: https://mariadb.com/kb/en/introduction-to-state-snapshot-transfers-ssts/ 
# wsrep_sst_method="mariabackup"
# wsrep_sst_auth="root:$MARIADB_ROOT_PASSWORD"
EOF