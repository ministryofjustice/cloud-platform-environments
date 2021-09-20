// package namespace contains required code to interact with a Cloud Platform namespace.
package namespace

import (
	"reflect"
	"testing"
)

func TestChangedInPR(t *testing.T) {
	type args struct {
		branchRef string
		token     string
		repo      string
		owner     string
	}
	tests := []struct {
		name    string
		args    args
		want    []string
		wantErr bool
	}{
		{
			name: "Fail with empty token",
			args: args{
				branchRef: "/refs/pull/5501/merge",
				token:     "",
				repo:      "cloud-platform-environments",
				owner:     "ministryofjustice",
			},
			wantErr: true,
			want:    nil,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := ChangedInPR(tt.args.branchRef, tt.args.token, tt.args.repo, tt.args.owner)
			if (err != nil) != tt.wantErr {
				t.Errorf("ChangedInPR() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("ChangedInPR() = %v, want %v", got, tt.want)
			}
		})
	}
}

func TestGetAllNamespaces(t *testing.T) {
	badHost := "https://obviouslyFakeURL/hosted_services"
	goodHost := "https://reports.cloud-platform.service.justice.gov.uk/hosted_services"

	type args struct {
		host *string
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		{
			name: "Pass faulty hostname",
			args: args{
				host: &badHost,
			},
			wantErr: true,
		},
		{
			name: "Pass correct hostname",
			args: args{
				host: &goodHost,
			},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := GetAllNamespaces(tt.args.host)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetAllNamespaces() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}

func TestGetNamespace(t *testing.T) {
	badHost := "https://obviouslyFakeURL/hosted_services"
	goodHost := "https://reports.cloud-platform.service.justice.gov.uk/hosted_services"

	type args struct {
		s    string
		host string
	}
	tests := []struct {
		name    string
		args    args
		wantErr bool
	}{
		{
			name: "Call correct namespace",
			args: args{
				s:    "abundant-namespace-dev",
				host: goodHost,
			},
			wantErr: false,
		},
		{
			name: "Call incorrect namespace",
			args: args{
				s:    "obviouslyFakeNamespace",
				host: goodHost,
			},
			wantErr: true,
		},
		{
			name: "Call incorrect hostname",
			args: args{
				s:    "abundant-namespace-dev",
				host: badHost,
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := GetNamespace(tt.args.s, tt.args.host)
			if (err != nil) != tt.wantErr {
				t.Errorf("GetNamespace() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}
