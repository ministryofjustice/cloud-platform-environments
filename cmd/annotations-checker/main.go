package main

import (
	"fmt"
	"os"
)

func main() {
	// retrieve the GitHub token
	token := os.Getenv("GITHUB_TOKEN")
	if token == "" {
		fmt.Println("GITHUB_TOKEN env var not set")
		return
	}

	// set org
	org := "https://github.com/ministryofjustice/cloud-platform-environments/"

	// create GitHub client
	client := NewGitHubClient(token)

	// validate annotations
	message, err := ValidateAnnotations(client, org)
	if err != nil {
		fmt.Println(err)
		return
	}

	fmt.Println(message)
}
