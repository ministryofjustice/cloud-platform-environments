package validate

import (
	"context"
	"log"
	"os"
	"rbac-check/client"
	"rbac-check/config"
	"rbac-check/get"
	"testing"
)

func TestGoodUserPermissions(t *testing.T) {
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

	repo := config.Repository{
		AdminTeam: "WebOps",
		Org:       "ministryofjustice",
	}

	teams := make(map[string]int)
	teams["WebOps"] = 0

	user.Id, _ = get.UserID(&opt, &user)

	valid, team, _ := UserPermissions(teams, &opt, &user, &repo)

	if !valid && team == "WebOps" {
		t.Errorf("The cloud-platform-moj bot user should be in the team webops. Want true; got %v", valid)
	}
}

func TestBadUserPermissions(t *testing.T) {
	teams := make(map[string]int)
	teams["test-webops"] = 0

	user := config.User{
		Username: "cloud-platform-moj",
	}

	opt := config.Options{
		Client: client.GitHubClient(os.Getenv("TEST_GITHUB_ACCESS")),
		Ctx:    context.Background(),
	}

	repo := config.Repository{
		AdminTeam: "WebOps",
		Org:       "ministryofjustice",
	}

	user.Id, _ = get.UserID(&opt, &user)

	valid, team, _ := UserPermissions(teams, &opt, &user, &repo)

	if valid && team == "test-webops" {
		t.Errorf("The cloud-platform-moj bot user isn't team %s. Want true; got %v", team, valid)
	}
}
