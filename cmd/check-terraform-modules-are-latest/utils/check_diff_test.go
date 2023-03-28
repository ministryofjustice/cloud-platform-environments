package utils

import (
	"errors"
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
	return Args{diff, mockedResponse}
}

func TestCheckModuleVersions(t *testing.T) {
	validAPIResponse := APIResponse{RepoName: "cloud-platform-terraform-foo", LatestVersion: "0.0.0"}
	validAPIResponseNoVersion := APIResponse{RepoName: "cloud-platform-terraform-foo", LatestVersion: ""}

	validMockedResponse := MockedAPIReturn{MockResponse: validAPIResponse, MockError: nil}
	validMockedResponseNoVersion := MockedAPIReturn{MockResponse: validAPIResponseNoVersion, MockError: nil}
	invalidMockedResponseNoVersion := MockedAPIReturn{MockResponse: validAPIResponse, MockError: nil}
	invalidResponse := MockedAPIReturn{MockResponse: validAPIResponse, MockError: errors.New("API is down!")}

	tests := []struct {
		name    string
		args    Args
		wantErr bool
	}{
		{"GIVEN no matches in the diff THEN don't fail", generateMockedReturns("no matches here", validMockedResponse), false},
		{"GIVEN an updated module with the correct version THEN don't fail", generateMockedReturns("+ github.com/ministryofjustice/cloud-platform-terraform-foo?ref=0.0.0\"", validMockedResponse), false},
		{"GIVEN multiple updated modules with versions AND the api returns versions THEN pass", generateMockedReturns("+ github.com/ministryofjustice/cloud-platform-terraform-foo?ref=0.0.0\"+ github.com/ministryofjustice/cloud-platform-terraform-foo?ref=0.0.0\"", validMockedResponse), false},
		{"GIVEN an updated module with no version AND the api returns no version THEN pass", generateMockedReturns("+ github.com/ministryofjustice/cloud-platform-terraform-foo\"", validMockedResponseNoVersion), false},
		{"GIVEN an updated module with no version AND the api returns a version THEN fail", generateMockedReturns("+ github.com/ministryofjustice/cloud-platform-terraform-foo\"", invalidMockedResponseNoVersion), true},
		{"GIVEN an updated module with a version AND the api returns a version BUT it is a different version THEN fail", generateMockedReturns("+ github.com/ministryofjustice/cloud-platform-terraform-foo?ref=1.1.1\"", validMockedResponse), true},
		{"GIVEN an API error THEN fail", generateMockedReturns("+ github.com/ministryofjustice/cloud-platform-terraform-foo?ref=1.1.1\"", invalidResponse), true},
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
