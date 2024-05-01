package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"

	"github.com/google/go-github/v39/github"
	"golang.org/x/oauth2"
	"gopkg.in/yaml.v2"
)

type Annotations struct {
	Kind           string `yaml:"kind"`
	SourceCodeRepo string `yaml:"cloud-platform.justice.gov.uk/source-code"`
	TeamName       string `yaml:"cloud-platform.justice.gov.uk/team-name"`
}

type KubernetesConfig struct {
	Metadata struct {
		Annotations Annotations `yaml:"annotations"`
	} `yaml:"metadata"`
}

func NewGitHubClient(token string) *github.Client {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	return github.NewClient(tc)
}

func ValidateAnnotations(client *github.Client, org, prEvent string) (string, error) {
	event, err := parsePREvent(prEvent)
	if err != nil {
		return "", err
	}

	changedFiles, namespaces, err := getChangedFilesAndNamespaces(client, org, event)
	if err != nil {
		return "", err
	}

	fileMap := make(map[string]*github.CommitFile)
	for _, file := range changedFiles {
		fileMap[*file.Filename] = file
	}

	foundNamespace := false
	for path := range fileMap {
		annotations, err := getAnnotations(path)
		if err != nil {
			return "", fmt.Errorf("Failed to get annotation from %s: %v", path, err)
		}

		if annotations.Kind == "Namespace" {
			foundNamespace = true
			passed, message := validateFile(client, org, path, annotations, namespaces)
			if passed {
				return message, nil
			}
		}
	}

	if !foundNamespace {
		return "No files with 'kind:Namespace' annotation found.", nil
	}

	return "All namespace validations passed successfully.", nil
}

func parsePREvent(prEvent string) (*github.PullRequestEvent, error) {
	event := &github.PullRequestEvent{}
	err := json.Unmarshal([]byte(prEvent), event)
	if err != nil {
		return nil, err
	}
	return event, nil
}

func getChangedFilesAndNamespaces(client *github.Client, org string, event *github.PullRequestEvent) ([]*github.CommitFile, []string, error) {
	changedFiles, err := getChangedFiles(client, org, event)
	if err != nil {
		return nil, nil, err
	}

	namespaces, err := getNamespaces(event)
	if err != nil {
		return nil, nil, err
	}

	return changedFiles, namespaces, nil
}

func getChangedFiles(client *github.Client, org string, event *github.PullRequestEvent) ([]*github.CommitFile, error) {
	var allFiles []*github.CommitFile
	opts := &github.ListOptions{PerPage: 100}

	for {
		commits, resp, err := client.PullRequests.ListCommits(context.Background(), org, *event.Repo.Name, *event.Number, opts)
		if err != nil {
			return nil, err
		}
		for _, commit := range commits {
			commitDetail, _, err := client.Repositories.GetCommit(context.Background(), org, *event.Repo.Name, commit.GetSHA(), nil)
			if err != nil {
				return nil, err
			}
			for _, file := range commitDetail.Files {
				if file.GetStatus() != "removed" {
					allFiles = append(allFiles, file)
				}
			}
		}
		if resp.NextPage == 0 {
			break
		}
		opts.Page = resp.NextPage
	}

	return allFiles, nil
}

func getNamespaces(event *github.PullRequestEvent) ([]string, error) {
	namespaces := []string{}

	if event.PullRequest.Body != nil {
		lines := strings.Split(*event.PullRequest.Body, "\n")
		for _, line := range lines {
			if strings.Contains(line, "namespace:") {
				ns := strings.TrimPrefix(line, "namespace:")
				ns = strings.TrimSpace(ns)
				namespaces = append(namespaces, ns)
			}
		}
	}

	return namespaces, nil
}

func getAnnotations(path string) (Annotations, error) {
	// read yaml file
	yamlFile, err := os.ReadFile(path)
	if err != nil {
		return Annotations{}, err
	}

	// parse yaml
	var config KubernetesConfig
	err = yaml.Unmarshal(yamlFile, &config)
	if err != nil {
		return Annotations{}, err
	}

	return config.Metadata.Annotations, nil
}

func validateFile(client *github.Client, org, path string, annotations Annotations, namespaces []string) (bool, string) {
	repo := annotations.SourceCodeRepo
	team := annotations.TeamName

	repoInfo, _, err := client.Repositories.Get(context.Background(), org, repo)
	if err != nil {
		return false, fmt.Sprintf("The repository, %s, does not exist.", repo)
	}

	if repoInfo.GetPrivate() {
		return false, fmt.Sprintf("The repository %s is private.", repo)
	}

	_, _, err = client.Teams.GetTeamBySlug(context.Background(), org, team)
	if err != nil {
		return false, fmt.Sprintf("The team %s does not exist or the PR owner isn't a member.", team)
	}

	return true, fmt.Sprintf("Annotations successfully validated for %s", path)
}
