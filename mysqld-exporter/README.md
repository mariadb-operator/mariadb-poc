## mysqld-exporter

#### Configure cluster

```bash
make cluster
make registry
make net
make install
```

#### Configuration

```bash
make monitoring-user
make exporter
```

### Get metrics

Create a port-forward in another terminal:
```bash
kubectl port-forward deployment/exporter 9104:9104
```

Curl exporter endpoints
```bash
curl http://localhost:9104/probe?target=mariadb-repl-0.mariadb-repl-internal.default.svc.cluster.local:3306
```