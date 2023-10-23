package app

import (
	"os"
	"reflect"
	"testing"
)

func TestGetNamespaceDetails(t *testing.T) {
	type args struct {
		folder string
	}
	tests := []struct {
		name    string
		args    args
		want    *Namespace
		wantErr bool
	}{
		{
			name: "GIVEN a namespace folder THEN return the namespace details",
			args: args{
				folder: "testdata/namespace",
			},
			want: &Namespace{
				Application:  "Namespace to test namespace yaml",
				BusinessUnit: "HQ",
				Environment:  "development",
				IsProduction: "false",
				Namespace:    "foobar",
				Owner:        "Cloud Platform: platforms@digital.justice.gov.uk",
				SlackChannel: "cloud-platform",
				SourceCode:   "https://github.com/ministryofjustice/cloud-platform",
			},
			wantErr: false,
		},
		{
			name: "GIVEN a namespace folder with no namespace.yaml THEN return an nil to continue",
			args: args{
				folder: "testdata/no-namespace",
			},
			want:    &Namespace{},
			wantErr: false,
		},
		{
			name: "GIVEN a namespace folder with a malformed namespace.yaml THEN return an error",
			args: args{
				folder: "testdata/malformed-namespace",
			},
			want:    &Namespace{},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := GetNamespaceDetails(tt.args.folder)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetNamespaceDetails() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("GetNamespaceDetails() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestNamespace_CreateRbPSPPrivilegedFile(t *testing.T) {
	type fields struct {
		Application           string
		BusinessUnit          string
		Environment           string
		GithubTeam            string
		InfrastructureSupport string
		IsProduction          string
		Namespace             string
		Owner                 string
		OwnerEmail            string
		SlackChannel          string
		SourceCode            string
		ReviewAfter           string
	}
	type args struct {
		templatePath string
		outputFile   string
	}
	tests := []struct {
		name    string
		fields  fields
		args    args
		wantErr bool
	}{
		{
			name: "GIVEN a namespace THEN create a rbac-psp-privileged.yaml file",
			fields: fields{
				Application:  "Namespace to test namespace yaml",
				BusinessUnit: "HQ",
				Environment:  "development",
				IsProduction: "false",
				Namespace:    "foobar",
				Owner:        "Cloud Platform: platforms@digital.justice.gov.uk",
				SlackChannel: "cloud-platform",
				SourceCode:   "https://github.com/ministryofjustice/cloud-platform",
			},
			args: args{
				templatePath: "../template/pspPrivRoleBinding.tmpl",
				outputFile:   "testdata/namespace/pspPrivRoleBinding.yaml",
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			ns := &Namespace{
				Application:  tt.fields.Application,
				BusinessUnit: tt.fields.BusinessUnit,
				Environment:  tt.fields.Environment,
				IsProduction: tt.fields.IsProduction,
				Namespace:    tt.fields.Namespace,
				Owner:        tt.fields.Owner,
				OwnerEmail:   tt.fields.OwnerEmail,
				SlackChannel: tt.fields.SlackChannel,
				SourceCode:   tt.fields.SourceCode,
			}
			if err := ns.CreateRbPSPPrivilegedFile(tt.args.templatePath, tt.args.outputFile); (err != nil) != tt.wantErr {
				t.Errorf("Namespace.CreateRbPSPPrivilegedFile() error = %v, wantErr %v", err, tt.wantErr)
			}
			defer os.Remove(tt.args.outputFile)
		})
	}
}
