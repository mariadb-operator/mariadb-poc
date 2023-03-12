CHANGE MASTER TO 
MASTER_HOST='mariadb-0.mariadb.default.svc.cluster.local',
MASTER_USER='repluser',
MASTER_PASSWORD='replsecret',
MASTER_CONNECT_RETRY=10;