CREATE USER 'repl'@'%' IDENTIFIED BY 'repl';
GRANT REPLICATION REPLICA ON *.* TO 'repl'@'%';

CREATE USER 'primary'@'%' IDENTIFIED BY 'primary';
GRANT ALL PRIVILEGES ON *.* TO 'primary'@'%';

CREATE USER 'readonly'@'%' IDENTIFIED BY 'readonly';
GRANT SELECT ON *.* TO 'readonly'@'%';

CREATE DATABASE primary_db;