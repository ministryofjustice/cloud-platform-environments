package utils

import (
	"errors"
	"strings"
	"testing"
)

type MockedAPIReturn struct {
	MockResponse APIResponse
	MockError    error
}

type Args struct {
	diff         string
	mockResponse MockedAPIReturn
}

func mockGetLatestModuleVersion(mockedReturn MockedAPIReturn) func(string) (APIResponse, error) {
	return func(moduleName string) (APIResponse, error) {
		return mockedReturn.MockResponse, mockedReturn.MockError
	}
}

func generateMockedReturns(diff string, mockedResponse MockedAPIReturn) Args {
	return Args{"diff --git a/main.tf b/main.tf\n" + diff, mockedResponse}
}

func TestCheckModuleVersions(t *testing.T) {
	validSHA := "0123456789abcdef0123456789abcdef01234567"
	differentSHA := "abcdef0123456789abcdef0123456789abcdef01"

	validAPIResponse := APIResponse{RepoName: "cloud-platform-terraform-foo", LatestVersion: "0.0.0", LatestSHA: validSHA}
	validAPIResponseNoVersion := APIResponse{RepoName: "cloud-platform-terraform-foo", LatestVersion: "", LatestSHA: ""}
	validMockedResponse := MockedAPIReturn{MockResponse: validAPIResponse, MockError: nil}
	validMockedResponseNoVersion := MockedAPIReturn{MockResponse: validAPIResponseNoVersion, MockError: nil}
	invalidMockedResponseWithVersion := MockedAPIReturn{MockResponse: validAPIResponse, MockError: nil}
	invalidResponse := MockedAPIReturn{MockResponse: validAPIResponse, MockError: errors.New("API is down!")}

	tests := []struct {
		name    string
		args    Args
		wantErr bool
	}{
		{"GIVEN no matches in the diff THEN don't fail", generateMockedReturns("no matches here", validMockedResponse), false},
		{"GIVEN an updated module with the correct version THEN don't fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=0.0.0"`, validMockedResponse), false},
		{"GIVEN multiple updated modules with versions AND the api returns versions THEN pass", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=0.0.0"`+"\n"+`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=0.0.0"`, validMockedResponse), false},
		{"GIVEN an updated module with no version AND the api returns no version THEN pass", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo"`, validMockedResponseNoVersion), false},
		{"GIVEN an updated module with no version AND the api returns a version THEN fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo"`, invalidMockedResponseWithVersion), true},
		{"GIVEN an updated module with a version AND the api returns a version BUT it is a different version THEN fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=1.1.1"`, validMockedResponse), true},
		{"GIVEN an updated module pinned to the latest SHA THEN don't fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=`+validSHA+`"`, validMockedResponse), false},
		{"GIVEN an updated module pinned to an old SHA THEN fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=`+differentSHA+`"`, validMockedResponse), true},
		{"GIVEN an updated module with an invalid ref THEN fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=foobar"`, validMockedResponse), true},
		{"GIVEN an API error THEN fail", generateMockedReturns(`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=1.1.1"`, invalidResponse), true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			getVersionFn := mockGetLatestModuleVersion(tt.args.mockResponse)

			if err := CheckModuleVersions(tt.args.diff, getVersionFn); (err != nil) != tt.wantErr {
				t.Errorf("CheckModuleVersions() error = %v, wantErr %v", err, tt.wantErr)
			}
		})
	}
}

func TestCheckModuleVersionsReportsAllFailures(t *testing.T) {
	latest := APIResponse{RepoName: "cloud-platform-terraform-foo", LatestVersion: "3.0.0", LatestSHA: "0123456789abcdef0123456789abcdef01234567"}
	getVersionFn := mockGetLatestModuleVersion(MockedAPIReturn{MockResponse: latest})

	diff := strings.Join([]string{
		"diff --git a/main.tf b/main.tf",
		`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=1.1.1"`,
		`+ source = "github.com/ministryofjustice/cloud-platform-terraform-foo?ref=3.0.0"`,
		`+ source = "github.com/ministryofjustice/cloud-platform-terraform-bar?ref=2.2.2"`,
	}, "\n")

	err := CheckModuleVersions(diff, getVersionFn)

	if err == nil {
		t.Fatal("CheckModuleVersions() expected an error, got nil")
	}

	msg := err.Error()

	if got := strings.Count(msg, "Fail:"); got != 2 {
		t.Errorf("expected 2 failures to be reported, got %d:\n%s", got, msg)
	}

	for _, want := range []string{"1.1.1 is not the latest 3.0.0", "2.2.2 is not the latest 3.0.0"} {
		if !strings.Contains(msg, want) {
			t.Errorf("expected error to mention %q:\n%s", want, msg)
		}
	}
}
