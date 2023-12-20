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
make servicemonitor
```

### Get metrics manually

Create a port-forward to the exporter in another terminal:
```bash
kubectl port-forward deployment/exporter 9104:9104
```
```bash
curl http://localhost:9104/probe?target=mariadb-repl-0.mariadb-repl-internal.default.svc.cluster.local:3306
curl http://localhost:9104/probe?target=mariadb-repl-1.mariadb-repl-internal.default.svc.cluster.local:3306
curl http://localhost:9104/probe?target=mariadb-repl-2.mariadb-repl-internal.default.svc.cluster.local:3306
```