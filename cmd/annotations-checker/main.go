package main

import (
	"fmt"
	"os"
	"path/filepath"
	// "golang.org/x/text/message"
)

func main() {
	owner := "ministryofjustice"
	repo := "github.com/ministryofjustice/"
	prNumber := ""
	token := os.Getenv("GITHUB_TOKEN")

	if token == "" {
		fmt.Println("GITHUB_TOKEN environment variable is not set")
		os.Exit(1)

		prFiles, err := fetchPRFiles(owner, repo, prNumber, token)
		if err != nil {
			fmt.Printf("Error fetching pr files: %v\n", err)
			os.Exit(1)
		}

		teams, err := fetchTeams(owner, token)
		if err != nil {
			fmt.Printf("Error fetching teams: %v\n", err)
			os.Exit(1)
		}

		for _, file := range prFiles {
			if filepath.Ext(file.Filename) == ".yaml" {
				valid, message := validateRemoteFile(file.RawURL, token, teams)
				fmt.Printf("Validation result for %s: %v - %s\n", file.Filename, valid, message)
			}
		}
	}
	// dir := "test-annotations"

	// err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
	// 	if err != nil {
	// 		return err
	// 	}
	// 	if !info.IsDir() && filepath.Ext(path) == ".yaml" {
	// 		valid, message := validateAnnotations(path)
	// 		fmt.Printf("validation result for %s: %v - %s\n", path, valid, message)
	// 	}
	// 	return nil
	// })
	// if err != nil {
	// 	fmt.Printf("Error walking the path %s: %v\n", dir, err)
	// }
}
