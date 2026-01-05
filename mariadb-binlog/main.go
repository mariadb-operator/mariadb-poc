package main

import (
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/go-mysql-org/go-mysql/mysql"
	"github.com/go-mysql-org/go-mysql/replication"
	"k8s.io/utils/ptr"
)

type BinlogMetadata struct {
	ServerId       uint32
	ServerVersion  string
	BinlogVersion  uint16
	LogPos         uint32
	FirstTimestamp uint32
	LastTimestamp  uint32
	PreviousGtids  []string
	FirstGtid      *string
	LastGtid       *string
	RotateEvent    bool
	StopEvent      bool
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
	var firstT, lastT string
	if m.FirstTimestamp == 0 {
		firstT = "<nil>"
	} else {
		firstT = time.Unix(int64(m.FirstTimestamp), 0).UTC().Format(time.RFC3339)
	}
	if m.LastTimestamp == 0 {
		lastT = "<nil>"
	} else {
		lastT = time.Unix(int64(m.LastTimestamp), 0).UTC().Format(time.RFC3339)
	}
	var prev string
	if len(m.PreviousGtids) == 0 {
		prev = "<nil>"
	} else {
		prev = strings.Join(m.PreviousGtids, ", ")
	}
	return fmt.Sprintf("ServerId: %d\nServerVersion: %s\nBinlogVersion: %d\nLogPos: %d\nFirstTimestamp: %s(raw:%d)\nLastTimestamp: %s(raw:%d)\nPreviousGTIDs: %s\nFirstGTID: %s\nLastGTID: %s\nRotateEvent: %t\nStopEvent: %t\n",
		m.ServerId, m.ServerVersion, m.BinlogVersion, m.LogPos,
		firstT, m.FirstTimestamp, lastT, m.LastTimestamp, prev, first, last, m.RotateEvent, m.StopEvent)
}

func GetBinlogMetadata(filename string) (*BinlogMetadata, error) {
	parser := replication.NewBinlogParser()
	parser.SetFlavor(mysql.MariaDBFlavor)
	parser.SetVerifyChecksum(false)
	parser.SetRawMode(true) // set to false for human-redable events. It will introduce parsing overhead.

	meta := BinlogMetadata{}
	var (
		rawFormatDescriptionEvent []byte
		rawGtidListEvent          []byte
		firstRawGtidEvent         []byte
		lastRawGtidEvent          []byte
	)

	err := parser.ParseFile(filename, 0, func(e *replication.BinlogEvent) error {
		// e.Dump(os.Stdout)
		meta.LogPos = e.Header.LogPos
		meta.ServerId = e.Header.ServerID

		// see: https://mariadb.com/docs/server/reference/clientserver-protocol/replication-protocol
		switch e.Header.EventType {
		case replication.FORMAT_DESCRIPTION_EVENT:
			rawFormatDescriptionEvent = e.RawData
		case replication.MARIADB_GTID_LIST_EVENT:
			rawGtidListEvent = e.RawData
		case replication.MARIADB_GTID_EVENT:
			if firstRawGtidEvent == nil {
				firstRawGtidEvent = e.RawData
			}
			lastRawGtidEvent = e.RawData
		case replication.ROTATE_EVENT:
			meta.RotateEvent = true
		case replication.STOP_EVENT:
			meta.StopEvent = true
		}
		if meta.FirstTimestamp == 0 {
			meta.FirstTimestamp = e.Header.Timestamp
		}
		meta.LastTimestamp = e.Header.Timestamp

		return nil
	})
	if err != nil {
		return nil, fmt.Errorf("error getting binlog metadata: %v", err)
	}

	if rawFormatDescriptionEvent != nil {
		formatDescription := &replication.FormatDescriptionEvent{}
		if err := formatDescription.Decode(rawFormatDescriptionEvent[replication.EventHeaderSize:]); err != nil {
			fmt.Printf("error decoding first format description event: %v", err)
			os.Exit(1)
		}
		meta.ServerVersion = formatDescription.ServerVersion
		meta.BinlogVersion = formatDescription.Version
	}
	if rawGtidListEvent != nil {
		listEvent := &replication.MariadbGTIDListEvent{}
		if err := listEvent.Decode(rawGtidListEvent[replication.EventHeaderSize:]); err != nil {
			fmt.Printf("error decoding first GTID list event: %v", err)
			os.Exit(1)
		}
		prevGtids := make([]string, len(listEvent.GTIDs))
		for i, gtid := range listEvent.GTIDs {
			prevGtids[i] = gtid.String()
		}
		meta.PreviousGtids = prevGtids
	}
	if firstRawGtidEvent != nil {
		firstGtid, err := decodeGTIDEvent(firstRawGtidEvent, meta.ServerId)
		if err != nil {
			fmt.Printf("error decoding first GTID event: %v", err)
			os.Exit(1)
		}
		meta.FirstGtid = ptr.To(firstGtid.GTID.String())
	}
	if lastRawGtidEvent != nil {
		lastGtid, err := decodeGTIDEvent(lastRawGtidEvent, meta.ServerId)
		if err != nil {
			fmt.Printf("error decoding last GTID event: %v", err)
			os.Exit(1)
		}
		meta.LastGtid = ptr.To(lastGtid.GTID.String())
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

var binlogs = []string{
	"binlogs/domain_id_0/mariadb-repl-bin.000001",
	"binlogs/domain_id_0/mariadb-repl-bin.000002",
	"binlogs/domain_id_0/mariadb-repl-bin.000003",
	"binlogs/domain_id_0/mariadb-repl-bin.000004",
	"binlogs/domain_id_0/mariadb-repl-bin.000005",
	"binlogs/domain_id_0/mariadb-repl-bin.000006",
	"binlogs/domain_id_0/mariadb-repl-bin.000007",
	"binlogs/domain_id_0/mariadb-repl-bin.000008",
	"binlogs/domain_id_0/mariadb-repl-bin.000009",
	"binlogs/domain_id_0/mariadb-repl-bin.000010",
	// "binlogs/domain_id_1/mariadb-repl-bin.000001",
	// "binlogs/domain_id_1/mariadb-repl-bin.000002",
}

func main() {
	for _, binlog := range binlogs {
		fmt.Printf("Getting binlog metadata from %s\n", binlog)
		meta, err := GetBinlogMetadata(binlog)
		if err != nil {
			fmt.Printf("error getting binlog metadata: %v", err)
			os.Exit(1)
		}
		fmt.Println("Got binlog metadata:")
		fmt.Println(meta)
	}
}
