package main

import (
	"bufio"
	"fmt"
	"log"
	"os"

	dir "golang.org/x/mod/sumdb/dirhash"
)

const fileName string = "./.checksum"
const base string = "./namespaces/live-1.cloud-platform.service.justice.gov.uk"

func main() {
	// DefaultHash is the default hash function used in new go.sum entries.
	var DefaultHash dir.Hash = dir.Hash1

	original, namespace := readAutoApprove(fileName)

	nsDir := base + "/" + namespace
	hashNs, _ := dir.HashDir(nsDir, namespace, DefaultHash)

	if compare(original, hashNs) {
		fmt.Println("Checksums match. Approve PR.")
	} else {
		log.Fatalln("Checksums do not match. Exiting.")
	}
}

func readAutoApprove(f string) (userHash, namespace string) {
	file, err := os.Open(f)
	if err != nil {
		log.Fatalln(err)
	}

	defer file.Close()

	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanLines)

	var lines []string
	for scanner.Scan() {
		lines = append(lines, scanner.Text())
	}

	namespace = lines[1]
	userHash = lines[2]

	return
}

func compare(prHash, gaHash string) (match bool) {
	if prHash == gaHash {
		match = true
	}

	return
}
