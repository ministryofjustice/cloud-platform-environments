// Package get is a getter package for all GitHub API calls
package get

import (
	"bufio"
	"bytes"
	"errors"
	"io"
	"log"
	"os"
	"reflect"
	"strings"

	"rbac-check/config"

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
// - The namespace doesn't yet exist and exists in the pull request.
func TeamName(namespace string, opt *config.Options, user *config.User, repo *config.Repository) ([]string, error) {
	repoOpts := &github.RepositoryContentGetOptions{}
	log.Println("Checking for rbac file for the given namespace in main branch")
	// We must first check to see if it exists in the main branch.
	file, ori, err := origin(namespace, opt, user, repo, repoOpts)
	if err != nil {
		log.Println(err)
	}

	// If the namespace doesn't exist yet, change the repository options to look at the users branch and try again.
	if ori == "none" {
		log.Println("Cant find namespace in main branch, checking for rbac in the PR")
		repoOpts = &github.RepositoryContentGetOptions{
			Ref: repo.Branch,
		}
		file, ori, err = origin(namespace, opt, user, repo, repoOpts)
		if err != nil {
			return nil, err
		}
		if ori == "none" {
			return nil, errors.New("Unable to find namespace in the PR")
		}
	}

	content, err := file.GetContent()
	if err != nil {
		return nil, err
	}
	return getGithubTeamName([]byte(content))
}

// getGithubTeamName reads the byte of data, decode and unmarshal the yaml input
// to the required struct and return a slice of team mentions in subjects
func getGithubTeamName(content []byte) ([]string, error) {

	var namespaceTeams []string
	// Parsing the yaml.
	decoder := yaml.NewDecoder(bytes.NewReader(content))
	// loop through multiple documents to omit empty documents
	for {
		// Storing the subject name in a slice.
		rbac := config.Rbac{}

		if err := decoder.Decode(&rbac); err != nil {
			// Break when there are no more documents to decode
			if err != io.EOF {
				return nil, err
			}
			break
		}

		if reflect.ValueOf(rbac).IsZero() {
			continue
		}

		// Filtering only subjects which are in the form of "github:*", this is to
		// protect against different kinds of subject such as ServiceAccount.
		for _, name := range rbac.Subjects {
			if strings.Contains(name.Name, "github") {
				str := strings.SplitAfter(string(name.Name), ":")
				namespaceTeams = append(namespaceTeams, str[1])
			}
		}
	}

	return namespaceTeams, nil
}

// origin takes a namespace name and returns the cluster it exists on.
func origin(namespace string, opt *config.Options, user *config.User, repo *config.Repository, repoOpts *github.RepositoryContentGetOptions) (*github.RepositoryContent, string, error) {
	primaryCluster := user.PrimaryCluster

	cluster := primaryCluster
	repo.Path = "namespaces/" + cluster + ".cloud-platform.service.justice.gov.uk/" + namespace + "/01-rbac.yaml"

	// Try the primary cluster first.
	file, _, resp, _ := opt.Client.Repositories.GetContents(opt.Ctx, repo.Org, repo.Name, repo.Path, repoOpts)

	// If the primary cluster returns 200, the namespace exists on the primary cluster.
	if resp.StatusCode == 200 {
		return file, cluster, nil
	} else {
		log.Println("Unable to locate the namespace in primary cluster, checking the PR.")
	}

	// If cluster fail to return a 200, the namespace exists in a PR.
	return nil, "none", nil
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
