package main

import (
	"fmt"
	"os"
	"time"

	"github.com/go-mysql-org/go-mysql/mysql"
	"github.com/go-mysql-org/go-mysql/replication"
	"k8s.io/utils/ptr"
)

type BinlogMetadata struct {
	Timestamp uint32
	LogPos    uint32
	ServerId  uint32
	FirstGtid *string
	LastGtid  *string
}

func (m BinlogMetadata) String() string {
	var first, last string
	if m.FirstGtid == nil {
		first = "<nil>"
	} else {
		first = *m.FirstGtid
	}
	if m.LastGtid == nil {
		last = "<nil>"
	} else {
		last = *m.LastGtid
	}
	t := time.Unix(int64(m.Timestamp), 0).UTC().Format(time.RFC3339)
	return fmt.Sprintf("Timestamp: %s(raw:%d)\nLogPos: %d\nServerId: %d\nFirstGTID: %s\nLastGTID: %s\n", t, m.Timestamp, m.LogPos, m.ServerId, first, last)
}

func GetBinlogMetadata(filename string) (*BinlogMetadata, error) {
	parser := replication.NewBinlogParser()
	parser.SetFlavor(mysql.MariaDBFlavor)
	parser.SetVerifyChecksum(false)
	parser.SetRawMode(true) // set to false for human-redable events. It will introduce parsing overhead.

	meta := BinlogMetadata{}
	var (
		firstRawGtidEvent []byte
		lastRawGtidEvent  []byte
	)

	err := parser.ParseFile(filename, 0, func(e *replication.BinlogEvent) error {
		e.Dump(os.Stdout)
		if e.Header.EventType == replication.MARIADB_GTID_EVENT {
			if firstRawGtidEvent == nil {
				firstRawGtidEvent = e.RawData
			}
			lastRawGtidEvent = e.RawData
		}
		meta.Timestamp = e.Header.Timestamp
		meta.LogPos = e.Header.LogPos
		meta.ServerId = e.Header.ServerID
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("error getting binlog metadata: %v", err)
	}

	if firstRawGtidEvent != nil {
		firstGtid, err := decodeGTIDEvent(firstRawGtidEvent, meta.ServerId)
		if err != nil {
			fmt.Printf("error decoding first GTID event: %v", err)
		} else {
			meta.FirstGtid = ptr.To(firstGtid.GTID.String())
		}
	}
	if lastRawGtidEvent != nil {
		lastGtid, err := decodeGTIDEvent(lastRawGtidEvent, meta.ServerId)
		if err != nil {
			fmt.Printf("error decoding last GTID event: %v", err)
		} else {
			meta.LastGtid = ptr.To(lastGtid.GTID.String())
		}
	}

	return &meta, nil
}

func decodeGTIDEvent(rawEvent []byte, serverId uint32) (*replication.MariadbGTIDEvent, error) {
	gtidEvent := &replication.MariadbGTIDEvent{}
	// See:
	// https://github.com/go-mysql-org/go-mysql/blob/a07c974ef5a34a8d0d7dfb543652c4ba2dec90cf/replication/parser.go#L149
	// https://github.com/wal-g/wal-g/blob/c98a8ea2d4afcb639e112164b7ce30316c4fbdb0/internal/databases/mysql/mysql_binlog.go#L76
	if err := gtidEvent.Decode(rawEvent[replication.EventHeaderSize:]); err != nil {
		return nil, err
	} else {
		// See:
		// https://github.com/go-mysql-org/go-mysql/blob/a07c974ef5a34a8d0d7dfb543652c4ba2dec90cf/replication/parser.go#L315
		// https://github.com/go-mysql-org/go-mysql/blob/a07c974ef5a34a8d0d7dfb543652c4ba2dec90cf/replication/event.go#L876
		gtidEvent.GTID.ServerID = serverId
	}
	return gtidEvent, nil
}

var (
	binlogFile = "binlogs/domain_id_0/mariadb-repl-bin-20251231114115.000008"

// binlogFile = "binlogs/domain_id_1/mariadb-repl-bin-20251231125242.000002"
)

func main() {
	fmt.Printf("Getting binlog metadata from %s\n", binlogFile)
	meta, err := GetBinlogMetadata(binlogFile)
	if err != nil {
		fmt.Printf("error getting binlog metadta: %v", err)
		os.Exit(1)
	}
	fmt.Println("Got binlog metadata:")
	fmt.Println(meta)
}
