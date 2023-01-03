package get

import (
	"context"
	"log"
	"os"
	"rbac-check/client"
	"rbac-check/config"
	"reflect"
	"testing"
)

// TestGetUserID attempts to get the user id of a robot user account.
func TestGetUserID(t *testing.T) {
	if os.Getenv("TEST_GITHUB_ACCESS") == "" {
		log.Fatalln("You must have a personal access token set in an env var called 'TEST_GITHUB_ACCESS'")
	}

	user := config.User{
		Username: "cloud-platform-moj",
	}

	opt := config.Options{
		Client: client.GitHubClient(os.Getenv("TEST_GITHUB_ACCESS")),
		Ctx:    context.Background(),
	}

	expected := int64(42068481)
	u, _ := UserID(&opt, &user)

	if int64(*u.ID) != expected {
		t.Errorf("The userID is not expected. want %v, got %v", expected, int64(*u.ID))
	}
}

// TestPrimaryTeamName attempts to get a team name from a yaml file in the
// primary cluster.
func TestPrimaryTeamName(t *testing.T) {
	namespace := "abundant-namespace-dev"

	user := config.User{
		PrimaryCluster: "live",
	}

	repo := config.Repository{
		AdminTeam: "webops",
		Name:      "cloud-platform-environments",
		Org:       "ministryofjustice",
	}

	opt := config.Options{
		Client: client.GitHubClient(os.Getenv("TEST_GITHUB_ACCESS")),
		Ctx:    context.Background(),
	}

	teams, _ := TeamName(namespace, &opt, &user, &repo)

	for _, team := range teams {
		if team != repo.AdminTeam {
			t.Errorf("Expecting: %s; got %s", repo.AdminTeam, team)
		}
	}
}

func Test_getGithubTeamName(t *testing.T) {
	type args struct {
		content []byte
	}
	tests := []struct {
		name    string
		args    args
		want    []string
		wantErr bool
	}{
		{
			name: "simple rolebinding",
			args: args{[]byte(
				`---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: test-admins
  namespace: test-ns
subjects:
  - kind: Group
    name: "github:test-team"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io`),
			},
			want:    []string{"test-team"},
			wantErr: false,
		},
		{
			name: "rolebinding with multiple subjects",
			args: args{[]byte(
				`---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: test-admins
  namespace: test-ns
subjects:
  - kind: Group
    name: "github:test-team"
    apiGroup: rbac.authorization.k8s.io
  - kind: Group
    name: "github:test-team-02"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io`),
			},
			want:    []string{"test-team", "test-team-02"},
			wantErr: false,
		},
		{
			name: "rolebinding with empty documents and comments",
			args: args{[]byte(
				`---
# Source: test/templates/01-rbac.yaml
# Bind admin role for namespace to team group
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: test-admins
  namespace: test-ns
subjects:
  - kind: Group
    name: "github:test-team"
    apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io

# Further roles defined in:
# - test-service-account.yaml`),
			},
			want:    []string{"test-team"},
			wantErr: false,
		},
		{
			name: "rolebinding with other documents like serviceaccount",
			args: args{[]byte(
				`kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: test-admins
  namespace: test-namespace
subjects:
  - kind: Group
    name: "github:test-team"
    apiGroup: rbac.authorization.k8s.io
    roleRef:
      kind: ClusterRole
      name: admin
      apiGroup: rbac.authorization.k8s.io
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: circleCI
  namespace: test-namespace
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: circleCI
  namespace: test-namespace
subjects:
- kind: ServiceAccount
  name: circleCI
  namespace: test-namespace
roleRef:
  kind: ClusterRole
  name: admin
  apiGroup: rbac.authorization.k8s.io`),
			},
			want:    []string{"test-team"},
			wantErr: false,
		},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			got, err := getGithubTeamName(tt.args.content)
			if (err != nil) != tt.wantErr {
				t.Errorf("getGithubTeamName() error = %v, wantErr %v", err, tt.wantErr)
				return
			}
			if !reflect.DeepEqual(got, tt.want) {
				t.Errorf("getGithubTeamName() = %v, want %v", got, tt.want)
			}
		})
	}
}
