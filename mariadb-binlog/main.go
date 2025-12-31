package main

import (
	"fmt"
	"log"
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
	Gtid      *string
}

func (m BinlogMetadata) String() string {
	var gtid string
	if m.Gtid == nil {
		gtid = "<nil>"
	} else {
		gtid = *m.Gtid
	}
	t := time.Unix(int64(m.Timestamp), 0).UTC().Format(time.RFC3339)
	return fmt.Sprintf("Timestamp: %s(raw:%d)\nLogPos: %d\nServerId: %d\nGTID: %s\n", t, m.Timestamp, m.LogPos, m.ServerId, gtid)
}

func GetBinlogMetadata(filename string) (*BinlogMetadata, error) {
	parser := replication.NewBinlogParser()
	parser.SetFlavor(mysql.MariaDBFlavor)
	parser.SetVerifyChecksum(false)
	parser.SetRawMode(true)

	meta := BinlogMetadata{}
	var rawGtidEvent []byte

	err := parser.ParseFile(filename, 0, func(e *replication.BinlogEvent) error {
		if e.Header.EventType == replication.MARIADB_GTID_EVENT {
			rawGtidEvent = e.RawData
		}
		meta.Timestamp = e.Header.Timestamp
		meta.LogPos = e.Header.LogPos
		meta.ServerId = e.Header.ServerID
		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("error getting binlog metadata: %v", err)
	}

	if rawGtidEvent != nil {
		gtidEvent := &replication.MariadbGTIDEvent{}
		// TODO: verify this decoding, currently not parsing domain and server id:  lastArchivedGtid: 0-0-262796
		if err := gtidEvent.Decode(rawGtidEvent[replication.EventHeaderSize:]); err != nil {
			log.Printf("error decoding GTID event: %v", err)
		} else {
			meta.Gtid = ptr.To(gtidEvent.GTID.String())
		}
	}

	return &meta, nil
}

var binlogFile = "binlogs/mariadb-repl-bin-20251231114115.000008"

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
