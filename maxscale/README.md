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

#### Resource configuration

Take into account these considerations when configuring the following maxscale parameters:
- [`threads`](https://mariadb.com/kb/en/mariadb-maxscale-6-mariadb-maxscale-configuration-guide/#threads): It must be set to the same value as cpu limits.
- [`query_classifier_cache_size`](https://mariadb.com/kb/en/mariadb-maxscale-6-mariadb-maxscale-configuration-guide/#query_classifier_cache_size): It must be set to 15% of memory limits. 

#### Create config

```bash
make config
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
[<img src="https://run.pstmn.io/button.svg" alt="Run In Postman" style="width: 128px; height: 32px;">](https://www.postman.com/mariadb-operator/workspace/mariadb-operator/collection/9776-74dfd54a-2b2b-451f-95ab-006e1d9d9998?action=share&creator=9776&active-environment=9776-a841398f-204a-48c8-ac04-6f6c3bb1d268)

#### High Availability

```bash
make ha
```

#### Sysbench

```bash
 make sysbench-mxs-prepare
 make sysbench-mxs
```

#### Automatic failover

```bash
POD=mariadb-repl-0 make delete-pod
```

#### Execute commands

```bash
make failover
make switchover
```

#### GUI

- [Conn](http://maxscale-conn.default.svc.cluster.local:8989)
- [RW Split](http://maxscale-rw-split.default.svc.cluster.local:8989)
- [API](http://maxscale-api.default.svc.cluster.local:8989)

#### Cleanup

```bash
make auth-delete
make config-delete
make conn-delete
make rw-split-delete
make api-delete
make cluster-delete
```