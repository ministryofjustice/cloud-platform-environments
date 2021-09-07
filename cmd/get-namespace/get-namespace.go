package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/google/go-github/v38/github"
	"golang.org/x/oauth2"
)

var (
	owner  = flag.String("owner", "ministryofjustice", "The owner of the GitHub repository")
	repo   = flag.String("repository", "cloud-platform-environments", "The repository of the Cloud Platform repository.")
	branch = flag.String("branch", os.Getenv("GITHUB_REF"), "GitHub pull request reference. Often obtained by a GitHub Action.")
	token  = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "Personal access token from GitHub.")
)

func main() {
	flag.Parse()

	if *token == "" {
		log.Println("Please set your GitHub token.")
	}

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{
			AccessToken: *token,
		},
	)

	str := strings.Split(*branch, "/")
	prId, err := strconv.Atoi(str[2])
	if err != nil {
		log.Fatalln(err)
	}

	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	repos, _, _ := client.PullRequests.ListFiles(ctx, *owner, *repo, prId, nil)

	for _, repo := range repos {
		if strings.Contains(*repo.Filename, "live") {
			fmt.Println(*repo.Filename)
		}
	}
}
