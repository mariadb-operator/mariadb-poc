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

[<img src="https://run.pstmn.io/button.svg" alt="Run In Postman" style="width: 128px; height: 32px;">](https://god.gw.postman.com/run-collection/9776-74dfd54a-2b2b-451f-95ab-006e1d9d9998?action=collection%2Ffork&source=rip_markdown&collection-url=entityId%3D9776-74dfd54a-2b2b-451f-95ab-006e1d9d9998%26entityType%3Dcollection%26workspaceId%3Da184b7e4-b1f7-405e-b9ec-ec62ed36dd27#?env%5BMaxScale%5D=W3sia2V5IjoidXJsIiwidmFsdWUiOiJodHRwOi8vbWF4c2NhbGUtYXBpLmRlZmF1bHQuc3ZjLmNsdXN0ZXIubG9jYWw6ODk4OSIsImVuYWJsZWQiOnRydWUsInR5cGUiOiJkZWZhdWx0In1d)

### GUI

- [Conn](http://maxscale-conn.default.svc.cluster.local:8989)
- [RW Split](http://maxscale-rw-split.default.svc.cluster.local:8989)
- [API](http://maxscale-api.default.svc.cluster.local:8989)