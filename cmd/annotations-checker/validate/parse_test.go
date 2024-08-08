package validate

import (
	"fmt"
	"os"
	"reflect"
	"testing"

	"github.com/google/go-github/v39/github"
)

func TestParse(t *testing.T) {
	client := &github.Client{}
	org := "ministryofjustice"

	validAnno := Annotations{
		TeamName:   "education-skills-work-employment",
		SourceCode: "https://github.com/ministryofjustice/hmpps-jobs-board-api",
	}

	invalidTeamAnno := Annotations{
		TeamName:   "",
		SourceCode: "https://github.com/ministryofjustice/cloud-platform-helloworld-ruby-app",
	}

	invalidSourceAnno := Annotations{
		TeamName:   "webops",
		SourceCode: "",
	}

	validBytes, readErr := os.ReadFile("./fixtures/valid.diff")
	if readErr != nil {
		t.Errorf("unexpected error fetching valid diff: %v", readErr)
		return
	}

	invalidTeamBytes, readErr := os.ReadFile("./fixtures/ivtn.diff")
	if readErr != nil {
		t.Fatalf("error while fetching invalid team diff: %v", readErr)
	}

	invalidSourceBytes, readErr := os.ReadFile("./fixtures/ivsc.diff")
	if readErr != nil {
		t.Fatalf("error while fetching onvalid source diff: %v", readErr)
	}

	tests := []struct {
		name        string
		diff        string
		expectedRes Annotations
		wantErr     bool
	}{
		{"GIVEN a valid diff THEN parse without errors", string(validBytes), validAnno, false},
		{"GIVEN a diff with an invalid TEAM NAME THEN parse with errors", string(invalidTeamBytes), invalidTeamAnno, true},
		{"GIVEN a diff with an invalid SOURCE CODE THEN parse with errors", string(invalidSourceBytes), invalidSourceAnno, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			fmt.Printf("Running test: %s\n", tt.name)
			res, err := Parse(client, org, tt.diff)
			if (err != nil) != tt.wantErr {
				t.Errorf("Parse() for %s: unexpected error status. got error: %v, wantErr: %v", tt.name, err, tt.wantErr)
				return
			}
			if !tt.wantErr {
				if !reflect.DeepEqual(res, &tt.expectedRes) {
					t.Errorf("Parse() = %v, want %v", res, &tt.expectedRes)
				}
			}
		})
	}
}
