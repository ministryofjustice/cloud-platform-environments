package main

import (
	"context"
	"fmt"
	"log" // logging library for error handling
	"os"
	"path/filepath" // for manipulating file paths and walking directories

	"github.com/google/go-github/v32/github" // GitHub API client library
	"golang.org/x/oauth2"                    // API requests authentication
	"gopkg.in/yaml.v2"
)

// Annotations structs to define the structure of annotations in the YAML file
type Annotations struct {
	SourceCodeRepo string `yaml:"cloud-platform.justice.gov.uk/source-code"`
	TeamName       string `yaml:"cloud-platform.justice.gov.uk/team-name"`
}

// hold the structure for the YAML file
type KubernetesConfig struct {
	Metadata struct {
		Annotations Annotations `yaml:"annotations"`
	} `yaml:"metadata"`
}

func main() {
	// retrieve the GitHub token
	githubToken := getEnv("GITHUB_TOKEN")
	org := "https://github.com/ministryofjustice/cloud-platform-environments/"

	// write the validation results to a file
	outputFile := createFile("validation_results.txt")
	defer outputFile.Close()

	// setup the GitHub client
	client := setupGitHubClient(githubToken)

	// filter files in the namespace directory
	processYAMLFiles(client, org, outputFile)
}

// retrieve an environment variables or throw an error if unfound
func getEnv(key string) string {
	value := os.Getenv(key)
	if value == "" {
		log.Fatalf("%s environment variable is not set", key)
	}
	return value
}

// create aand write to a file, but throw an error if this fails
func createFile(filename string) *os.File {
	file, err := os.Create(filename)
	if err != nil {
		log.Fatalf("Failed to create an output file: %v.", err)
	}
	return file
}

// initialize a new gitHub client using the 0auth token
func setupGitHubClient(token string) *github.Client {
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
	tc := oauth2.NewClient(ctx, ts)
	client := github.NewClient(tc)

	return client
}

// process YAML files
func processYAMLFiles(client *github.Client, org string, outputFile *os.File) {
	err := filepath.Walk("namespaces", func(path string, info os.FileInfo, err error) error {
		// error handling during Walking
		if err != nil {
			fmt.Fprintf(outputFile, "Error walking through the namespaces directory: %v\n", err)
			return err
		}

		// skip anything that has nothing to do with YAML files
		if info.IsDir() || filepath.Ext(path) != ".yaml" {
			return nil
		}
		// read and parse the YAML file
		configData, err := os.ReadFile(path)
		if err != nil {
			fmt.Fprintf(outputFile, "Error reading the config file %s: %v\n", path, err)
			return nil
		}
		var config KubernetesConfig
		err = yaml.Unmarshal(configData, &config)
		if err != nil {
			fmt.Fprintf(outputFile, "Error parsing config file %s: %v\n", path, err)
			return nil
		}
		// validate annotations
		validateAnnotations(client, org, path, config.Metadata.Annotations, outputFile)
		return nil
	})

	if err != nil {
		fmt.Fprintf(outputFile, "Failed to walk through the namespaces directory: %v\n", err)
	}

	// check if any validation message was written to the file
	checkValidationResults(outputFile)
}

// validate team name and source code repo
func validateAnnotations(client *github.Client, org, path string, annotations Annotations, outputFile *os.File) {
	repo := annotations.SourceCodeRepo
	team := annotations.TeamName

	// validate the github repo
	_, _, err := client.Repositories.Get(context.Background(), org, repo)
	if err != nil {
		fmt.Fprintf(outputFile, "The repository either does not exist or has been set to private in %s: %v\n", org, repo, path, err)
	}

	// validate the github team
	_, _, err = client.Teams.GetTeamBySlug(context.Background(), org, team)
	if err != nil {
		fmt.Fprintf(outputFile, "Team validation failed as the team could not be found in %s: %v\n", team, org, path, err)
	}
}

// write a success message to the file if no validation messages were written to it
func checkValidationResults(outputFile *os.File) {
	// retrieve the file's info to check its size
	info, err := outputFile.Stat()
	if err != nil {
		log.Printf("Could not stat the file: %v", err)
		return
	}

	// if the file size was 0, it would mean err == nil
	if info.Size() == 0 {
		fmt.Fprintf(outputFile, "All annotation validations were successful.")
	}
}
