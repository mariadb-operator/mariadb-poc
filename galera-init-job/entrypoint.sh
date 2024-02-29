#!/bin/bash

source /usr/local/bin/docker-entrypoint.sh

mysql_note "Entrypoint script for MariaDB Server ${MARIADB_VERSION} started."

mysql_check_config "mariadbd"

# Load various environment variables
docker_setup_env "mariadbd"
docker_create_db_directories

# If container is started as root user, restart as dedicated mysql user
if [ "$(id -u)" = "0" ]; then
  mysql_note "Switching to dedicated user 'mysql'"
  exec gosu mysql "${BASH_SOURCE[0]}" "mariadbd"
fi

docker_verify_minimum_env

mysql_note "Starting MariaDB init"

docker_mariadb_init "mariadbd"