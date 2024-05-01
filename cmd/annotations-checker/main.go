package main

import (
	"fmt"
	"os"
)

func main() {
	token := os.Getenv("GITHUB_TOKEN")
	if token == "" {
		fmt.Println("GITHUB_TOKEN env var not set")
		return
	}

	org := "https://github.com/ministryofjustice/"

	client := NewGitHubClient(token)

	prEvent := os.Getenv("PR_EVENT_DATA")
	if prEvent == "" {
		fmt.Println("PR_EVENT_DATA environment variable is not set")
		return
	}

	message, err := ValidateAnnotations(client, org, prEvent)
	if err != nil {
		fmt.Printf("Error during validation %v\n", err)
		return
	}

	fmt.Println(message)
}
