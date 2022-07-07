package get

import (
	"context"
	"log"
	"os"
	"testing"

	"rbac-check/client"
	"rbac-check/config"
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
		PrimaryCluster:   "live",
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
