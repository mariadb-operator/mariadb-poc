CREATE USER 'repluser'@'%' IDENTIFIED BY 'replsecret';
GRANT REPLICATION REPLICA ON *.* TO 'repluser'@'%';
CREATE DATABASE primary_db;