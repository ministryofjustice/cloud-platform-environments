package main

import (
	"context"
	"log"
	"os"
	"strconv"

	"github.com/google/go-github/v50/github"
	"github.com/ministryofjustice/github-actions/check-terraform-modules-are-latest/utils"
)

func initEnvVars() (string, int, string) {
	repoName, repoNamePresent := os.LookupEnv("REPO_NAME")
	if repoName == "" || !repoNamePresent {
		log.Fatal("REPO_NAME is not set")
	}

	prNumberStr, prNumberPresent := os.LookupEnv("PR_NUMBER")
	if prNumberStr == "" || !prNumberPresent {
		log.Fatal("PR_NUMBER is not set")
	}

	prNumber, err := strconv.Atoi(prNumberStr)

	if err != nil {
		log.Fatal("PR_NUMBER is not a valid int", err)
	}

	apiURL, apiURLPresent := os.LookupEnv("API_URL")
	if apiURL == "" || !apiURLPresent {
		log.Fatal("API_URL is not set")
	}

	return repoName, prNumber, apiURL
}

func main() {
	// pass in the PR number and the repo name and api url
	repoName, prNumber, apiURL := initEnvVars()

	client := github.NewClient(nil)
	diff, _, err := client.PullRequests.GetRaw(context.Background(), "ministryofjustice", repoName, prNumber, github.RawOptions{Type: github.RawType(2)})

	if err != nil {
		log.Fatal(err)
	}

	getModuleVersionFn := utils.GetLatestModuleVersion(apiURL)

	versionError := utils.CheckModuleVersions(diff, getModuleVersionFn)

	if versionError != nil {
		log.Fatal(versionError)
	}
}
