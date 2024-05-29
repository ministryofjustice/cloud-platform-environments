package main

import (
	"fmt"
	"os"

	"github.com/ministryofjustice/cloud-platform-environments/cmd/annotations-checker/init_github"
	"github.com/ministryofjustice/cloud-platform-environments/cmd/annotations-checker/validate"
)

func main() {
	org := "ministryofjustice"
	token := os.Getenv("GITHUB_TOKEN")
	prEvent := os.Getenv("PR_EVENT")

	if token == "" {
		fmt.Println("GITHUB_TOKEN environment variable is not set")
		os.Exit(1)
	}

	if prEvent == "" {
		fmt.Println("PR_EVENT environment variable is not set")
		os.Exit(1)
	}

	client := init_github.NewGitHubClient(token)

	// diff := "https://patch-diff.githubusercontent.com/raw/ministryofjustice/cloud-platform-environments/pull/21897.diff"

	annotations, err := validate.Parse(client, org, prEvent)
	if err != nil {
		fmt.Printf("Error parsing pr files: %v\n", err)
		os.Exit(1)
	}

	validate.Validate(client, org, annotations)
}
