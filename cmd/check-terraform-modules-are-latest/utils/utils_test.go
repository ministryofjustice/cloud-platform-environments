package utils

import (
	"testing"
)

func Test_getModuleVersion(t *testing.T) {
	tests := []struct {
		name string
		args string
		want string
	}{
		{"GIVEN a string with a version matching x.y.z format THEN return the version", "foobar=1.2.3", "1.2.3"},
		{"GIVEN a string with a version matching x.y.z format THEN return the version", "foobar=14.29.3234", "14.29.3234"},
		{"GIVEN a string that has a 2 part semver version in the y.z format THEN return the semver", "foobar=1.2", "1.2"},
		{"GIVEN a string with no version THEN return any empty string", "foobar=", ""},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			if got := getModuleVersion(tt.args); got != tt.want {
				t.Errorf("getModuleVersion() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetModuleNameAndVersion(t *testing.T) {
	tests := []struct {
		name  string
		args  string
		want  string
		want1 bool
		want2 string
	}{
		{"GIVEN a string with a repo name and a version THEN return the repo name, bool if there's a version and the version", "github.com/ministryofjustice/foo?ref=v123.456.789", "foo", true, "123.456.789"},
		{"GIVEN a string with a repo name and no version THEN return the repo name, bool if there's a version and an empty string", "github.com/ministryofjustice/foo", "foo", false, ""},
		{"GIVEN a string with a repo name and a 2 part semver THEN return the repo name, bool if there's a version and the semver", "github.com/ministryofjustice/foo?ref=1.2", "foo", true, "1.2"},
		{"GIVEN a string with a repo name and an invalid query param THEN return the repo name, bool if there's a version and an empty string", "github.com/ministryofjustice/foo?XXX=1.2", "foo", false, ""},
		{"GIVEN a string with an invalid repo name THEN return an empty string", "github.com/ministryofjustice/", "", false, ""},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, got1, got2 := getModuleNameAndVersion(tt.args)
			if got != tt.want {
				t.Errorf("GetModuleNameAndVersion() got = %v, want %v", got, tt.want)
			}
			if got1 != tt.want1 {
				t.Errorf("GetModuleNameAndVersion() got1 = %v, want %v", got1, tt.want1)
			}
			if got2 != tt.want2 {
				t.Errorf("GetModuleNameAndVersion() got2 = %v, want %v", got2, tt.want2)
			}
		})
	}
}
