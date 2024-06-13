## MariaDB TLS

### Deployment

```bash
make deploy
```

### One-way TLS

```bash
mariadb -u root -pmariadb -h 127.0.0.1 \
  --ssl-verify-server-cert --ssl-ca=/tmp/pki/server-ca.crt
```