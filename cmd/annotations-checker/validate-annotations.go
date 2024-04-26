package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"

	"github.com/google/go-github/v32/github" // GitHub API client library
	// "github.com/ministryofjustice/cloud-platform-environments/pkg/namespace"
	"golang.org/x/oauth2" // API requests authentication
	// "google.golang.org/genproto/googleapis/api/annotations"
	"gopkg.in/yaml.v2"
)

// Annotations structs to define the structure of annotations in the YAML file
type Annotations struct {
	Kind           string `yaml:"kind"`
	SourceCodeRepo string `yaml:"cloud-platform.justice.gov.uk/source-code"`
	TeamName       string `yaml:"cloud-platform.justice.gov.uk/team-name"`
}

// hold the structure for the YAML file
type KubernetesConfig struct {
	Metadata struct {
		Annotations Annotations `yaml:"annotations"`
	} `yaml:"metadata"`
}

// gitHub client
func NewGitHubClient(token string) *github.Client {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)
	return client
}

// validate team name and source code repo
func ValidateAnnotations(client *github.Client, org string) (string, error) {
	// get namespace directory
	namespacesDir := "/path/to/namespaces"
	files, err := os.ReadDir(namespacesDir)
	if err != nil {
		return "", fmt.Errorf("Failed to read namespaces directory: %v", err)
	}

	// check if kind:Namespace exists in any file
	foundNamespace := false
	for _, file := range files {
		if !file.IsDir() {
			path := filepath.Join(namespacesDir, file.Name())
			annotations, err := getAnnotations(path)
			if err != nil {
				return "", fmt.Errorf("Failed to get annotation from %s: %v", path, err)
			}

			if annotations.Kind == "Namespace" {
				foundNamespace = true
				passed, message := validateFile(client, org, path, annotations)
				if passed {
					return message, nil
				} else {
					return "", fmt.Errorf(message)
				}
			}
		}
	}

	// if kind:Namespace isn't found, do nothing
	if !foundNamespace {
		return "", nil
	}

	return "No files with 'kind:Namespace' annotation found. Check Passed.", nil
}

// retrieve annotations from yaml file
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

// validate yaml file
func validateFile(client *github.Client, org, path string, annotations Annotations) (bool, string) {
	repo := annotations.SourceCodeRepo
	team := annotations.TeamName

	// validate the repo
	repository, _, err := client.Repositories.Get(context.Background(), org, repo)
	if err != nil {
		return false, fmt.Sprintf("The repository, %s, does not exist.", repo)
	}

	if repository.GetPrivate() {
		return false, fmt.Sprintf("The repository %s is private.", repo)
	}

	// validate team
	_, _, err = client.Teams.GetTeamBySlug(context.Background(), org, team)
	if err != nil {
		return false, fmt.Sprintf("The team %s does not exist or the PR owner isn't a member.", team)
	}

	// if everything checks out, return success message
	return true, fmt.Sprintf("Annotations successfully validated for %s", path)
}
