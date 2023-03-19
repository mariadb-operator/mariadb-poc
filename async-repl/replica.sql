CHANGE MASTER TO 
MASTER_HOST='mariadb-0.mariadb.default.svc.cluster.local',
MASTER_USER='repl',
MASTER_PASSWORD='repl',
MASTER_CONNECT_RETRY=10;