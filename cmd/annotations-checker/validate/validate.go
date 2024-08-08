package validate

import (
	"context"
	"fmt"

	"github.com/google/go-github/v39/github"
)

func Validate(client *github.Client, org string, annotations *Annotations) (bool, string) {
	repo := annotations.SourceCode
	team := annotations.TeamName

	repoInfo, _, err := client.Repositories.Get(context.Background(), org, repo)
	if err != nil {
		return false, fmt.Sprintf("The repository, %s, does not exist.", repo)
	}

	if repoInfo.GetPrivate() {
		return false, fmt.Sprintf("The repository %s is private.", repo)
	}

	_, _, err = client.Teams.GetTeamBySlug(context.Background(), org, team)
	if err != nil {
		return false, fmt.Sprintf("The team %s does not exist or the PR owner isn't a member.", team)
	}

	return true, fmt.Sprintf("Annotations successfully validated")
}
