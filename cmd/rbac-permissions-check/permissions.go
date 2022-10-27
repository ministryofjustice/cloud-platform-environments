package main

import (
	"context"
	"flag"
	"log"
	"os"

	"rbac-check/client"
	"rbac-check/config"
	"rbac-check/get"
	"rbac-check/validate"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/namespace"
	ghaction "github.com/sethvargo/go-githubactions"
)

var (
	token          = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "Personal access token from GitHub.")
	branch         = flag.String("branch", os.Getenv("BRANCH"), "Branch of changes in GitHub.")
	branchRef      = flag.String("branchRef", os.Getenv("GITHUB_REF"), "GitHub branch reference.")
	username       = flag.String("user", os.Getenv("PR_OWNER"), "Branch of changes in GitHub.")
	repo           = flag.String("repository", "cloud-platform-environments", "The repository of the Cloud Platform repository.")
	org            = flag.String("org", "ministryofjustice", "Name of the orgnanisation i.e. ministryofjustice.")
	adminTeam      = flag.String("admin", "WebOps", "Admin team looking after repository.")
	primaryCluster = flag.String("primary", "live", "Name of the primary cluster in use.")
)

func main() {
	flag.Parse()

	// Fail if the relevant flags or environment variables haven't set.
	// token = a personal access token from GitHub
	// branch = the branch name of your PR
	// username = the github username used to create the PR.
	// All of these values will be passed upstream by a GitHub action.
	if *token == "" || *branch == "" || *username == "" || *branchRef == "" {
		log.Fatalln("You need to specify a non-empty value for token, branch and username.")
	}

	user := config.User{
		PrimaryCluster: *primaryCluster,
		Username:       *username,
	}

	opt := config.Options{
		Client: client.GitHubClient(*token),
		Ctx:    context.Background(),
	}

	repo := config.Repository{
		AdminTeam: *adminTeam,
		Branch:    *branch,
		Name:      *repo,
		Org:       *org,
	}

	// Get slice of all namespaces changed in a PR.
	namespaces, err := namespace.ChangedInPR(*branchRef, *token, repo.Name, repo.Org)
	if err != nil {
		log.Fatalf("Unable to get list of namespaces changed in PR: %e", err)
	}

	// Call the GitHub API for the rbac team name of each namespace in the namespaces variable.
	// The teams are stored in a map to ensure we don't duplicate. Maps are best for
	// deduplication in Go.
	namespaceTeams := make(map[string]int)
	for _, ns := range namespaces {
		teams, err := get.TeamName(ns, &opt, &user, &repo)
		if err != nil {
			log.Fatalln("Unable to get team names:", err)
		}
		for _, team := range teams {
			if namespaceTeams[team] == 0 {
				namespaceTeams[team] = 1
			} else {
				namespaceTeams[team]++
			}
		}
	}

	// Add the admin team so they can make changes to any namespace.
	namespaceTeams[repo.AdminTeam] = 1

	// Convert the username string into a GitHub user ID. This is used later, to compare the
	// list of users in a team.
	user.Id, err = get.UserID(&opt, &user)
	if err != nil {
		log.Fatalln("Unable to fetch userID", err)
	}

	// Call the GitHub API to confirm if the user exists in the GitHub team name.
	valid, team, err := validate.UserPermissions(namespaceTeams, &opt, &user, &repo)
	if err != nil {
		log.Fatalln("Unable to check if the user is valid:", err)
	}

	// Send result back to GitHub Action.
	if valid {
		log.Println("\n The user:", user.Id.GetName(), "\n is in team:", team)
		ghaction.SetOutput("reviewOutput", "true")
	} else {
		log.Println("\n The user:", user.Id.GetName(), "\n can't be found in teams:", namespaceTeams)
		ghaction.SetOutput("reviewOutput", "false")
		ghaction.SetOutput("reviewOwner", user.Username)
		ghaction.SetOutput("reviewTeam", team)
	}
}
