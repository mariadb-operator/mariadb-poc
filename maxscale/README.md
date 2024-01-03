## MaxScale

#### Configure cluster

```bash
make cluster
make registry
make net
make install
```

#### Configure MariaDB

```bash
make mariadb-repl
```

#### Configure auth

```bash
make auth
```

#### Connection based routing

```bash
make conn
```

#### Read write split

```bash
make rw-split
```

#### REST API

```bash
make api
```

### GUI

- [Conn](http://maxscale-conn.default.svc.cluster.local:8989)
- [RW Split](http://maxscale-rw-split.default.svc.cluster.local:8989)
- [API](http://maxscale-api.default.svc.cluster.local:8989)