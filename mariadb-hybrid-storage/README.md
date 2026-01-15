## MariaDB hybrid storage

In this PoC we will be provisioning a `MariaDB` cluster formed by 2 `Pods` using different `StorageClasses`:
- `mariadb-repl-0`: Using [rook-ceph](https://github.com/rook/rook) as distributed storage.
- `mariadb-repl-1`: Using [topolvm](https://github.com/topolvm/topolvm) as local storage.

To achieve this, `rook-ceph` will be used as default `StorageClass` and we will pre-provision a PVC for `mariadb-repl-1` by matching the `PVC` name expected by the `StatefulSet`: `storage-<mariadb-name>`.