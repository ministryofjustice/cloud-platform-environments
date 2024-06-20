package validate

import (
	"testing"

	"github.com/google/go-github/v39/github"
)

func TestParse(t *testing.T) {
	client := &github.Client{}
	org := "ministryofjustice"

	validDiffURL := "https://github.com/ministryofjustice/cloud-platform-environments/pull/21897.diff"
	validDiff, err := GetDiff(validDiffURL)
	if err != nil {
		t.Errorf("unexpected error fetching valid diff: %v", err)
		return
	}

	// test case 1: passes passing a raw diff for a valid PR
	annotations, err := Parse(client, org, validDiff)
	if err != nil {
		t.Errorf("unexpected error for valid PR: %v", err)
	}

	expectedTeamName := "education-skills-work-employment"
	expectedSourceCode := "https://github.com/ministryofjustice/hmpps-jobs-board-api"
	if annotations.TeamName != expectedTeamName {
		t.Errorf("Excpeted team name '%s', got '%s'", expectedTeamName, annotations.TeamName)
	}
	if annotations.SourceCode != expectedSourceCode {
		t.Errorf("Expected source code '%s', got '%s'", expectedSourceCode, annotations.SourceCode)
	}

	// test case 2: invalid pr fails containing incorrect team name
	invalidTeamNameDiffURL := "https://github.com/ministryofjustice/cloud-platform-environments/pull/23707.diff"
	invalidTeamNameDiff, err := GetDiff(invalidTeamNameDiffURL)
	if err != nil {
		t.Errorf("unexpected error fetching invalid team name dff: %v", err)
		return
	}
	_, err = Parse(client, org, invalidTeamNameDiff)
	if err == nil {
		t.Errorf("Expected an error for invalid team name, but got none")
	}

	// test case 3: invalid PR fails containing incorrect source code repo
	invalidSourceCodeDiffURL := "https://github.com/ministryofjustice/cloud-platform-environments/pull/23730.diff"
	invalidSourceCodeDiff, err := GetDiff(invalidSourceCodeDiffURL)
	if err != nil {
		t.Errorf("unexpected error fetching invalid source code diff: %v", err)
		return
	}
	_, err = Parse(client, org, invalidSourceCodeDiff)
	if err == nil {
		t.Errorf("Expected an error for invalid source code repo, but got none")
	}
}
