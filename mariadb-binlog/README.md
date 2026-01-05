## MariaDB binlog

Parse and display binary log events from a MariaDB server.

```bash
❯ go run main.go

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000001
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 358
FirstTimestamp: 2025-12-30T13:33:58Z(raw:1767101638)
LastTimestamp: 2025-12-30T20:52:57Z(raw:1767127977)
PreviousGTIDs: <nil>
FirstGTID: <nil>
LastGTID: <nil>
RotateEvent: false
StopEvent: true

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000002
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 3753792
FirstTimestamp: 2025-12-30T20:52:59Z(raw:1767127979)
LastTimestamp: 2025-12-30T20:55:27Z(raw:1767128127)
PreviousGTIDs: <nil>
FirstGTID: 0-10-250080
LastGTID: 0-10-254512
RotateEvent: true
StopEvent: false

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000003
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 6491014
FirstTimestamp: 2025-12-30T20:55:27Z(raw:1767128127)
LastTimestamp: 2025-12-30T20:56:22Z(raw:1767128182)
PreviousGTIDs: 0-10-254512
FirstGTID: 0-10-254513
LastGTID: 0-10-262175
RotateEvent: true
StopEvent: false

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000004
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 343488
FirstTimestamp: 2025-12-30T20:56:22Z(raw:1767128182)
LastTimestamp: 2025-12-30T20:56:25Z(raw:1767128185)
PreviousGTIDs: 0-10-262175
FirstGTID: 0-10-262176
LastGTID: 0-10-262580
RotateEvent: true
StopEvent: false

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000005
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 74142
FirstTimestamp: 2025-12-30T20:56:25Z(raw:1767128185)
LastTimestamp: 2025-12-30T20:56:26Z(raw:1767128186)
PreviousGTIDs: 0-10-262580
FirstGTID: 0-10-262581
LastGTID: 0-10-262667
RotateEvent: true
StopEvent: false

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000006
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 56355
FirstTimestamp: 2025-12-30T20:56:26Z(raw:1767128186)
LastTimestamp: 2025-12-30T20:56:26Z(raw:1767128186)
PreviousGTIDs: 0-10-262667
FirstGTID: 0-10-262668
LastGTID: 0-10-262733
RotateEvent: true
StopEvent: false

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000007
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 53814
FirstTimestamp: 2025-12-30T20:56:26Z(raw:1767128186)
LastTimestamp: 2025-12-30T20:56:27Z(raw:1767128187)
PreviousGTIDs: 0-10-262733
FirstGTID: 0-10-262734
LastGTID: 0-10-262796
RotateEvent: true
StopEvent: false

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000008
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 24899681
FirstTimestamp: 2025-12-30T20:56:27Z(raw:1767128187)
LastTimestamp: 2025-12-30T21:15:36Z(raw:1767129336)
PreviousGTIDs: 0-10-262796
FirstGTID: 0-10-262797
LastGTID: 0-10-292193
RotateEvent: false
StopEvent: true

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000009
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 935
FirstTimestamp: 2025-12-31T09:33:09Z(raw:1767173589)
LastTimestamp: 2025-12-31T11:37:32Z(raw:1767181052)
PreviousGTIDs: 0-10-292193
FirstGTID: 0-10-292194
LastGTID: 0-10-292196
RotateEvent: false
StopEvent: true

Getting binlog metadata from binlogs/domain_id_0/mariadb-repl-bin.000010
Got binlog metadata:
ServerId: 10
ServerVersion: 11.8.5-MariaDB-ubu2404-log
BinlogVersion: 4
LogPos: 2210
FirstTimestamp: 2025-12-31T11:39:42Z(raw:1767181182)
LastTimestamp: 2025-12-31T11:40:41Z(raw:1767181241)
PreviousGTIDs: 0-10-292196
FirstGTID: 0-10-292197
LastGTID: 0-10-292206
RotateEvent: false
StopEvent: true
```