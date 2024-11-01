package main

import (
	"crypto/tls"
	"crypto/x509"
	"database/sql"
	"log"
	"os"

	"github.com/go-sql-driver/mysql"
)

func main() {
	rootCertPool := x509.NewCertPool()
	ca, err := os.ReadFile("/tmp/pki/ca/server.crt")
	if err != nil {
		log.Fatalf("Error reading CA: %v", err)
	}
	if ok := rootCertPool.AppendCertsFromPEM(ca); !ok {
		log.Fatal("Failed to append CA cert")
	}

	clientCert := make([]tls.Certificate, 0, 1)
	certs, err := tls.LoadX509KeyPair("/tmp/pki/client.crt", "/tmp/pki/client.key")
	if err != nil {
		log.Fatalf("Error loading keypair: %v", err)
	}
	clientCert = append(clientCert, certs)

	mysql.RegisterTLSConfig("mariadb", &tls.Config{
		RootCAs:      rootCertPool,
		Certificates: clientCert,
		MinVersion:   tls.VersionTLS12,
	})

	db, err := sql.Open("mysql", "tom@tcp(127.0.0.1:3306)/?tls=mariadb")
	if err != nil {
		log.Fatalf("Error opening connection to database: %v", err)
	}
	if err := db.Ping(); err != nil {
		log.Fatalf("Error pinging database: %v", err)
	}
	log.Println("Connected")

	defer func() {
		if err := db.Close(); err != nil {
			log.Fatalf("Error closing connection to database: %v", err)
		}
		log.Println("Disconnected")
	}()

	if row := db.QueryRow("SELECT 1;"); row.Err() != nil {
		log.Fatalf("Error querying database: %v", row.Err())
	}
	log.Println("Successfully run query")
}
