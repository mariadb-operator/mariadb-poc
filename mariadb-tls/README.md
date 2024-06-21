## MariaDB TLS

Follow the sections below in order to understand how to establish TLS connections with MariaDB:

### Deployment

```bash
make deploy
```

### Port-forward

```bash
kubectl port-forward mariadb-0 3306:3306
```

### One-way TLS

```bash
mariadb -u root -pmariadb -h 127.0.0.1 \
  --ssl-ca=/tmp/pki/ca/server.crt \
  --ssl-verify-server-cert
```

### Two-way TLS

- Create users:

```bash
CREATE USER 'alice'@'%' REQUIRE x509;
CREATE USER 'bob'@'%' REQUIRE ISSUER '/CN=client-ca';
CREATE USER 'tom'@'%' REQUIRE ISSUER '/CN=client-ca' AND SUBJECT '/CN=client';
CREATE USER 'john'@'%' REQUIRE ISSUER '/CN=mycorp-ca' AND SUBJECT '/CN=john';
```

- Connect with the previous users providing a certificate:

```bash
mariadb -u alice -h 127.0.0.1 \
  --ssl-cert=/tmp/pki/client.crt \
  --ssl-key=/tmp/pki/client.key \
  --ssl-ca=/tmp/pki/ca/server.crt \
  --ssl-verify-server-cert
mariadb -u bob -h 127.0.0.1 \
  --ssl-cert=/tmp/pki/client.crt \
  --ssl-key=/tmp/pki/client.key \
  --ssl-ca=/tmp/pki/ca/server.crt \
  --ssl-verify-server-cert
mariadb -u tom -h 127.0.0.1 \
  --ssl-cert=/tmp/pki/client.crt \
  --ssl-key=/tmp/pki/client.key \
  --ssl-ca=/tmp/pki/ca/server.crt \
  --ssl-verify-server-cert
mariadb -u john -h 127.0.0.1 \
  --ssl-cert=/tmp/pki/client.crt \
  --ssl-key=/tmp/pki/client.key \
  --ssl-ca=/tmp/pki/ca/server.crt \
  --ssl-verify-server-cert
```

Note that, when attempting to log in as `john`, the following error is returned on the server side:

```bash
2024-06-14  0:59:43 10 [Note] X509 issuer mismatch: should be '/CN=mycorp-ca' but is '/CN=client-ca'
2024-06-14  0:59:43 10 [Warning] Access denied for user 'john'@'localhost' (using password: NO)
```

- Connect with the previous users providing a certificate from a Go program:

```bash
go run main.go
```