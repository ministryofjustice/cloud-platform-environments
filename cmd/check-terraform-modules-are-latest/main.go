package main

import (
	"context"
	"log"
	"net/http"
	"os"
	"strconv"

	"github.com/google/go-github/v50/github"
	"github.com/ministryofjustice/cloud-platform-environments/cmd/check-terraform-modules-are-latest/utils"
	"golang.org/x/oauth2"
)

func initEnvVars() (string, int, string, string) {
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

	ghToken, ghTokenPresent := os.LookupEnv("GH_TOKEN")
	if ghToken == "" || !ghTokenPresent {
		log.Fatal("GH_TOKEN is not set")
	}
	return repoName, prNumber, apiURL, ghToken
}

func initOAuth2(ghToken string) (*http.Client, context.Context) {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: ghToken},
	)
	tc := oauth2.NewClient(ctx, ts)

	return tc, ctx
}

func main() {
	// pass in the PR number and the repo name and api url
	repoName, prNumber, apiURL, ghToken := initEnvVars()
	oauthClient, ctx := initOAuth2(ghToken)

	client := github.NewClient(oauthClient)
	diff, _, err := client.PullRequests.GetRaw(ctx, "ministryofjustice", repoName, prNumber, github.RawOptions{Type: github.RawType(1)})

	if err != nil {
		log.Fatal(err)
	}

	getModuleVersionFn := utils.GetLatestModuleVersion(apiURL)

	versionError := utils.CheckModuleVersions(diff, getModuleVersionFn)

	if versionError != nil {
		log.Fatal(versionError)
	}
}
