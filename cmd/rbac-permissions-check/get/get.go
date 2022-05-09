// Package get is a getter package for all GitHub API calls
package get

import (
	"bufio"
	"log"
	"os"
	"rbac-check/config"
	"strings"

	"github.com/google/go-github/v35/github"
	"gopkg.in/yaml.v2"
)

// UserID takes an Options and User data type from the caller and returns
// the users GitHub user object.
func UserID(opt *config.Options, user *config.User) (*github.User, error) {
	userID, _, err := opt.Client.Users.Get(opt.Ctx, user.Username)
	if err != nil {
		return nil, err
	}

	return userID, nil
}

// TeamName takes a single namespace, finds out what cluster it belongs to and returns a slice of teams in the rbac
// file of that namespace. We have three potential cases here:
// - The namespace exists in the primaryCluster directory structure.
// - The namespace exists in the secondaryCluster directory structure,
// - The namespace doesn't yet exist and exists in the pull request.
func TeamName(namespace string, opt *config.Options, user *config.User, repo *config.Repository) ([]string, error) {
	repoOpts := &github.RepositoryContentGetOptions{}

	// We must first check to see if it exists in the primary or secondary clusters.
	ori, err := origin(namespace, opt, user, repo, repoOpts)
	if err != nil {
		log.Println(err)
	}

	// If the namespace doesn't exist yet, change the repository options to look at the users branch and try again.
	if ori == "none" {
		repoOpts = &github.RepositoryContentGetOptions{
			Ref: repo.Branch,
		}
		ori, err = origin(namespace, opt, user, repo, repoOpts)
		if err != nil {
			return nil, err
		}
	}

	// Now we know where the namespace sits we can attempt to get the contents of the rbac file from the GitHub API.
	repo.Path = "namespaces/" + ori + ".cloud-platform.service.justice.gov.uk/" + namespace + "/01-rbac.yaml"
	file, _, _, err := opt.Client.Repositories.GetContents(opt.Ctx, repo.Org, repo.Name, repo.Path, repoOpts)
	if err != nil {
		return nil, err
	}

	cont, err := file.GetContent()
	if err != nil {
		return nil, err
	}

	// Parsing the yaml.
	fullName := config.Rbac{}

	err = yaml.Unmarshal([]byte(cont), &fullName)
	if err != nil {
		return nil, err
	}

	// Storing the subject name in a slice. The subject name has to be in the form of "github:*", this is to
	// protect against different kinds of subject such as ServiceAccount.
	var namespaceTeams []string
	for _, name := range fullName.Subjects {
		if strings.Contains(name.Name, "github") {
			str := strings.SplitAfter(string(name.Name), ":")
			namespaceTeams = append(namespaceTeams, str[1])
		}
	}

	return namespaceTeams, nil
}

// origin takes a namespace name and returns the cluster (primary or secondary) it exists on.
func origin(namespace string, opt *config.Options, user *config.User, repo *config.Repository, repoOpts *github.RepositoryContentGetOptions) (string, error) {
	secondaryCluster := user.SecondaryCluster
	primaryCluster := user.PrimaryCluster

	cluster := primaryCluster
	repo.Path = "namespaces/" + cluster + ".cloud-platform.service.justice.gov.uk/" + namespace + "/01-rbac.yaml"

	// Try the primary cluster first.
	_, _, resp, _ := opt.Client.Repositories.GetContents(opt.Ctx, repo.Org, repo.Name, repo.Path, repoOpts)

	// If the primary cluster returns 200, the namespace exists on the primary cluster.
	if resp.StatusCode == 200 {
		return cluster, nil
	} else {
		// If the primary cluster doesn't return a 200, then try the secondary.
		cluster = secondaryCluster
		// We have to set the user path again to pick up the new cluster.
		repo.Path = "namespaces/" + cluster + ".cloud-platform.service.justice.gov.uk/" + namespace + "/01-rbac.yaml"
		_, _, resp, err := opt.Client.Repositories.GetContents(opt.Ctx, repo.Org, repo.Name, repo.Path, repoOpts)
		if err != nil {
			log.Println("Unable to locate the namespace in primary or secondary cluster, checking the PR.")
		}
		if resp.StatusCode == 200 {
			return cluster, nil
		}
	}

	// If both clusters fail to return a 200, the namespace exists in a PR.
	return "none", nil
}

// Namespaces takes a file name containing the namespaces changed in a PR and returns them
// in a map.
func Namespaces(fileName string) (map[string]int, error) {
	namespaces := make(map[string]int)

	file, err := os.Open(fileName)
	if err != nil {
		return namespaces, err
	}
	scanner := bufio.NewScanner(file)
	scanner.Split(bufio.ScanWords)

	// To avoid duplication a map was used.
	for scanner.Scan() {
		if namespaces[scanner.Text()] == 0 {
			namespaces[scanner.Text()] = 1
		} else {
			namespaces[scanner.Text()]++
		}
	}

	return namespaces, nil
}
