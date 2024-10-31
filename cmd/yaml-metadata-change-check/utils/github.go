package utils

import (
	"context"
	"fmt"
	"log"
	"strings"

	"github.com/google/go-github/v64/github"
)

var (
	ctx = context.Background()
)

func GitHubClient(token string) *github.Client {
	client := github.NewClient(nil).WithAuthToken(token)

	_, resp, err := client.Users.Get(ctx, "")
	if err != nil {
		fmt.Printf("\nerror: %v\n", err)
		return nil
	}

	// Rate.Limit should most likely be 5000 when authorized.
	log.Printf("Rate: %#v\n", resp.Rate)

	// If a Token Expiration has been set, it will be displayed.
	if !resp.TokenExpiration.IsZero() {
		log.Printf("Token Expiration: %v\n", resp.TokenExpiration)
	}

	return client
}

func GetPullRequestBranch(client *github.Client, o, r string, n int) (string, error) {
	pull, _, err := client.PullRequests.Get(ctx, o, r, n)
	if err != nil {
		return "", fmt.Errorf("error fetching pull request: %w", err)
	}
	return *pull.Head.Ref, nil
}

// ListFiles retrieves a list of commit files for each pull request in a GitHub repository.
// It takes a GitHub client and a context as input parameters.
// It returns a slice of commit files, and an error if any.
func GetPullRequestFiles(client *github.Client, o, r string, n int) ([]*github.CommitFile, *github.Response, error) {
	fmt.Printf("%s %s %d", o, r, n)
	files, resp, err := client.PullRequests.ListFiles(ctx, o, r, n, nil)
	if err != nil {
		return nil, nil, fmt.Errorf("error fetching files: %w", err)
	}

	return files, resp, err
}

func SelectFile(file *github.CommitFile) *github.CommitFile {
	// file filename contains dashboard in the name return file
	if strings.Contains(*file.Filename, "namespaces/live") && strings.Contains(*file.Filename, ".yaml") {
		return file
	} else {
		return nil
	}
}

func GetFileContent(client *github.Client, file *github.CommitFile, owner, repo, ref string) (*github.RepositoryContent, error) {
	opts := &github.RepositoryContentGetOptions{
		Ref: ref,
	}

	content, _, _, err := client.Repositories.GetContents(ctx, owner, repo, *file.Filename, opts)
	if err != nil {
		fmt.Printf("Error fetching file content: %v\n", err)
		return nil, err
	}

	return content, nil
}

func DecodeContent(content *github.RepositoryContent) (string, error) {
	decodeContent, err := content.GetContent()
	if err != nil {
		fmt.Printf("Error decoding file content: %v\n", err)
		return "", err
	}

	return decodeContent, nil
}
