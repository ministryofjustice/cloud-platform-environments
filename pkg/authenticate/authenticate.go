package authenticate

import (
	"context"
	"errors"

	"github.com/google/go-github/github"
	"golang.org/x/oauth2"
)

// GitHubClient takes a GitHub personal access key as a string and builds
// and returns a GitHub client to the caller.
func GitHubClient(token string) (*github.Client, error) {
	if token == "" {
		return nil, errors.New("Personal access token is empty, unable to create GitHub client.")
	}

	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{
			AccessToken: token,
		},
	)
	tc := oauth2.NewClient(ctx, ts)

	return github.NewClient(tc), nil
}
