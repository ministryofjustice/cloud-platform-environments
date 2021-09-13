// Package client implements the github client.
package client

import (
	"context"

	"github.com/google/go-github/v35/github"
	"golang.org/x/oauth2"
)

// GitHubClient takes a GitHub personal access key as a string and builds
// and returns a GitHub client to the caller.
func GitHubClient(token string) *github.Client {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: token},
	)

	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)

	return client
}
