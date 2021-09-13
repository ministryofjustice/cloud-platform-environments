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
