// Package validate will perform the lookup and compare functions of the
// rbac check.
package validate

import (
	"rbac-check/config"

	"github.com/google/go-github/v35/github"
)

// UserPermissions takes a map of strings containing the rbac team names of each MoJ Cloud Platform namespace,
// along with a GitHub user and the Options and User types defined by its caller. For each team in the
// namespaceTeams map, it'll grab all members of the team and confirm if the user ID of the member
// (in the githubUser variable) matches a user ID in the team. If so, the function will return true.
func UserPermissions(namespaceTeams map[string]int, opt *config.Options, user *config.User, repo *config.Repository) (bool, string, error) {
	teamOpts := &github.TeamListTeamMembersOptions{}
	// Loop over all teams in namespaceTeams map.
	for team := range namespaceTeams {
		// Grab each github member of the team
		members, _, err := opt.Client.Teams.ListTeamMembersBySlug(opt.Ctx, repo.Org, team, teamOpts)
		if err != nil {
			return false, "", nil
		}
		// Loop over each member of the team and confirm if githubUser exists
		for _, member := range members {
			if member.GetID() == user.Id.GetID() {
				// if the githubUser exists in the team, return true and publish the team name.
				return true, team, nil
			}
		}
	}

	return false, "", nil
}
