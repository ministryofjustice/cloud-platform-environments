// package namespace contains required code to interact with a Cloud Platform namespace.
package namespace

import (
	"context"
	"errors"
	"log"
	"strconv"
	"strings"

	"github.com/google/go-github/v38/github"
	"golang.org/x/oauth2"
)

// ChangedInPR takes a GitHub branch reference (usually provided by a GitHub Action), a
// personal access token with Read org permissions, the name of a repository and the owner.
// It queries the GitHub API for all changes made in a PR. If the PR contains changes to a namespace
// it returns a deduplicated slice of namespace names.
func ChangedInPR(branchRef, token, repo, owner string) ([]string, error) {
	if token == "" {
		return nil, errors.New("You must have a valid GitHub token.")
	}

	client := githubClient(token)

	// branchRef is expected in the format:
	// "refs/pull/<pull request number>/merge"
	// This is usually populated by a GitHub action.
	str := strings.Split(branchRef, "/")
	prId, err := strconv.Atoi(str[2])
	if err != nil {
		log.Fatalln(err)
	}

	repos, _, _ := client.PullRequests.ListFiles(context.Background(), owner, repo, prId, nil)

	var namespaceNames []string
	for _, repo := range repos {
		if strings.Contains(*repo.Filename, "live") {
			// namespaces filepaths are assumed to come in
			// the format: namespaces/live-1.cloud-platform.service.justice.gov.uk/<namespaceName>
			s := strings.Split(*repo.Filename, "/")
			namespaceNames = append(namespaceNames, s[2])
		}
	}

	return deduplicateList(namespaceNames), nil
}

// deduplicateList will simply take a slice of strings and
// return a deduplicated version.
func deduplicateList(s []string) (list []string) {
	keys := make(map[string]bool)

	for _, entry := range s {
		if _, value := keys[entry]; !value {
			keys[entry] = true
			list = append(list, entry)
		}
	}

	return
}

//githubClient returns a GitHub client to allow authenticated communications
func githubClient(token string) github.Client {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{
			AccessToken: token,
		},
	)
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	return *client
}
