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
	diffUrl := os.Getenv("DIFF_URL")

	if token == "" {
		fmt.Println("GITHUB_TOKEN environment variable is not set")
		os.Exit(1)
	}

	if diffUrl == "" {
		fmt.Println("DIFF_URL environment variable is not set")
		os.Exit(1)
	}

	client := init_github.NewGitHubClient(token)

	// TODO: check that the diff is a add or a update not deletion
	diff, getDiffErr := validate.GetDiff(diffUrl)
	if getDiffErr != nil {
		fmt.Printf("Error getting diff URL: %v\n", getDiffErr)
		os.Exit(1)
	}

	annotations, err := validate.Parse(client, org, diff)
	if err != nil {
		fmt.Printf("Error parsing pr files: %v\n", err)
		os.Exit(1)
	}

	validate.Validate(client, org, annotations)
}
