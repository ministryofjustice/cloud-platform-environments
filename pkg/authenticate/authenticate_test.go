package authenticate

import (
	"reflect"
	"testing"

	"github.com/google/go-github/github"
)

func TestGitHubClient(t *testing.T) {
	type args struct {
		token string
	}
	tests := []struct {
		name    string
		args    args
		want    *github.Client
		wantErr bool
	}{
		{
			name: "When passed an empty token, fail.",
			args: args{
				token: "",
			},
			wantErr: true,
			want:    nil,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := GitHubClient(tt.args.token)
			if (err != nil) != tt.wantErr {
				t.Errorf("GitHubClient() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("GitHubClient() = %v, want %v", got, tt.want)
			}
		})
	}
}
