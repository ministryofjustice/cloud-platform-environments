package validate

import (
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

	validBytes, readErr := os.ReadFile("./fixtures/valid.diff")
	if readErr != nil {
		t.Errorf("unexpected error fetching valid diff: %v", readErr)
		return
	}

	tests := []struct {
		name        string
		diff        string
		expectedRes Annotations
		wantErr     bool
	}{
		{"GIVEN a valid diff THEN parse without errors", string(validBytes), validAnno, false},
		// {"GIVEN a diff with an invalid TEAM NAME THEN parse with errors", string(invalidTeamBytes), invalidTeamAnno, true},
		// {"GIVEN a diff with an invalid SOURCE CODE THEN parse with errors", string(invalidSourceBytes), invalidSourceAnno, true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			res, err := Parse(client, org, tt.diff)
			if err != nil && !tt.wantErr {
				t.Errorf("Unexpected error: %v %v", tt.wantErr, err)
			}

			if reflect.DeepEqual(res, tt.expectedRes) {
				t.Errorf("Error result struct does not equal expected actual result")
			}
		})
	}
}
