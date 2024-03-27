package main

import (
	"bytes"
	"context"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/google/go-github/v32/github"
	"gopkg.in/yaml.v2"
)

// githubclienr interface that satisfies mockgithubclient and githubclient
type GitHubClient interface {
	RepositoriesGet(ctx context.Context, owner, repo string) (*github.Repository, *github.Response, error)
	TeamsGetTeamBySlug(ctx context.Context, org, slug string) (*github.Team, *github.Response, error)
}

// sample implementation for githubclient interface
type MockGitHubClient struct {
	RepositoriesGetFunc    func(ctx context.Context, owner, repo string) (*github.Repository, *github.Response, error)
	TeamsGetTeamBySlugFunc func(ctx context.Context, org, slug string) (*github.Team, *github.Response, error)
}

func (m *MockGitHubClient) RepositoriesGet(ctx context.Context, owner, repo string) (*github.Repository, *github.Response, error) {
	return m.RepositoriesGetFunc(ctx, owner, repo)
}

func (m *MockGitHubClient) TeamsGetTeamBySlug(ctx context.Context, org, slug string) (*github.Team, *github.Response, error) {
	return m.TeamsGetTeamBySlugFunc(ctx, org, slug)
}

// an helper function for github response
func createMockResponse(statusCode int) *github.Response {
	return &github.Response{
		Response: &http.Response{
			StatusCode: statusCode,
			Body:       io.NopCloser(bytes.NewBufferString("")),
		},
	}
}

// test the unmarshaling of YAML data
func TestUnmarshalYAML(t *testing.T) {
	yamlData := `
metadata:
	annotations:
		cloud-platform.justice.gov.uk/source-code
		cloud-platform.justice.gov.uk/team-name
`

	var config KubernetesConfig
	err := yaml.Unmarshal([]byte(yamlData), &config)
	if err != nil {
		t.Fatalf("yaml.Unmarshal() error: %v", err)
	}
	if config.Metadata.Annotations.SourceCodeRepo != "test-repo" || config.Metadata.Annotations.TeamName != "test-team" {
		t.Errorf("Expected SourceCodeRepo to be 'test-repo', got %s", config.Metadata.Annotations.SourceCodeRepo)
	}
	if config.Metadata.Annotations.TeamName != "test-team" {
		t.Errorf("Expected TeamName to be 'test-team', got: '%s'", config.Metadata.Annotations.TeamName)
	}
}

// test the validation of annotations
func TestValidateAnnotations(t *testing.T) {
	annotations := Annotations{SourceCodeRepo: "valid-repo", TeamName: "valid-team"}
	org := "test-org"
	path := "test/path.yaml"

	mockClient := MockGitHubClient{
		RepositoriesGetFunc: func(ctx context.Context, owner, repo string) (*github.Repository, *github.Response, error) {
			return &github.Repository{}, createMockResponse{200}, nil
		},
		TeamsGetTeamBySlugFunc: func(ctx context.Context, org, slug string) (*github.Team, *github.Response, error) {
			return &github.Team{}, createMockResponse{200}, nil
		},
	}

	var outputFile bytes.Buffer
	validateAnnotations(&mockClient, org, path, annotations, &outputFile)

	if outputFile.Len() != 0 {
		t.Errorf("validateAnnotations() unexpected output, got: %s instead of %s", &outputFile.String())
	}
}

// tes processYAMLFiles function
func TestProcessYAMLFiles(t *testing.T) {
	// temporary directory
	tempDir := t.TempDir()

	// create a valid YAML file inside it
	validFilePath := filepath.Join(tempDir, "valid.yaml")
	validContent := []byte(`
metadata:
	annotations:
		cloud-platform.justice.gov.uk/source-code
		cloud-platform.justice.gov.uk/team-name
`)
	if err := os.WriteFile(validFilePath, validContent, 644); err != nil {
		t.Fatalf("Unable to create valid YAML file: %v", err)
	}

	// mock github client that imitates valid responses
	mockClient := MockGitHubClient{
		RepositoriesGetFunc: func(ctx context.Context, owner, repo string) (*github.Repository, *github.Response, error) {
			return &github.Repository{}, createMockResponse{200}, nil
		},
		TeamsGetTeamBySlugFunc: func(ctx context.Context, org, slug string) (*github.Team, *github.Response, error) {
			return &github.Team{}, createMockResponse{200}, nil
		},
	}

	var outputFile bytes.Buffer
	processYAMLFiles(&mockClient, "test-org", &outputFile, tempDir)

	// check for unexpected validation messages
	if outputFile.Len() != 0 {
		t.Errorf("Expected no validation messages for valid YAML files, got: %s", &outputFile.String())
	}
}

// test main function's behaviour
func TestMainSuccer(t *testing.T) {
	tempDir := t.TempDir()
	os.Setenv("GITHUB_TOKEN", "test-token")
	os.Setenv("NAMESPACES_DIR", tempDir)

	validFilePath := filepath.Join(tempDir, "valid.yaml")
	validContent := []byte(`
metadata:
	annotations:
		cloud-platform.justice.gov.uk/source-code
		cloud-platform.justice.gov.uk/team-name
`)

	err := os.WriteFile(validFilePath, validContent, 644)
	if err != nil {
		t.Fatalf("Failed to write valid YAML file: %v", err)
	}

	r, w, _ := os.Pipe()
	originalStdout := os.Stdout
	os.Stdout = w

	main()

	w.Close()
	out, _ := io.ReadAll(r)
	os.Stdout = originalStdout

	expectedOutput := "All annotation validations were successful.\n"
	if !strings.Contains(string(out), expectedOutput) {
		t.Errorf("Expected success message %q, but got %q", expectedOutput, string(out))
	}

	os.Unsetenv("GITHUB_TOKEN")
	os.Unsetenv("NAMESPACES_DIR")
}

// test main function's behaviour if GITHUB_TOKEN was missing
func TestMainMissingGhToken(t *testing.T) {
	originalToken := os.Getenv("GITHUB_TOKEN")
	os.Unsetenv("GITHUB_TOKEN")

	r, w, _ := os.Pipe()
	originalStdout := os.Stdout
	os.Stdout = w

	main()

	w.Close()
	out, _ := io.ReadAll(r)
	os.Stdout = originalStdout

	if originalToken != "" {
		os.Setenv("GITHUB_TOKEN", originalToken)
	}

	expectedOutput := "GITHUB_TOKEN environment variable is not set."
	if !strings.Contains(string(out), expectedOutput) {
		t.Errorf("Expected error message %q, but got %q", expectedOutput, string(out))
	}
}
