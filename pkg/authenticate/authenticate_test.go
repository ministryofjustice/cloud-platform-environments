package authenticate

import (
	"reflect"
	"testing"

	"github.com/google/go-github/github"
	"k8s.io/client-go/kubernetes"
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

func TestKubeConfigFromS3Bucket(t *testing.T) {
	type args struct {
		bucket     string
		s3FileName string
		clusterCtx string
		region     string
	}
	tests := []struct {
		name          string
		args          args
		wantClientset *kubernetes.Clientset
		wantErr       bool
	}{
		{
			name: "Unauthenticated request to bucket should err",
			args: args{
				bucket:     "realbucketname",
				s3FileName: "doesntMatter",
				clusterCtx: "irrelevantCluster",
				region:     "eu-west-2",
			},
			wantErr: true,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			_, err := KubeConfigFromS3Bucket(tt.args.bucket, tt.args.s3FileName, tt.args.clusterCtx, tt.args.region)
			if (err != nil) != tt.wantErr {
				t.Errorf("KubeConfigFromS3Bucket() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
		})
	}
}
