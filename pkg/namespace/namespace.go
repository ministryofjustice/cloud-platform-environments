// package namespace contains required code to interact with a Cloud Platform namespace.
package namespace

import (
	"context"
	"encoding/json"
	"errors"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/authenticate"
)

type Namespace struct {
	Name             string        `json:"namespace"`
	Application      string        `json:"application"`
	BusinessUnit     string        `json:"business_unit"`
	TeamName         string        `json:"team_name"`
	TeamSlackChannel string        `json:"team_slack_channel"`
	GithubURL        string        `json:"github_url"`
	DeploymentType   string        `json:"deployment_type"`
	DomainNames      []interface{} `json:"domain_names"`
}

// HoodawReport contains the json to go struct of the hosted_services endpoint.
type AllNamespaces struct {
	Namespaces []Namespace `json:"namespace_details"`
}

// func (ns *Namespace) GetRbacGroup(token string) error {
// 	client, err := authenticate.GitHubClient(token)
// 	if err != nil {
// 		return err
// 	}

// 	nsPath := fmt.Sprintf("namespaces/%s.cloud-platform.service.justice.gov.uk/%s/01.rbac.yaml", ns.Cluster, ns.Name)

// 	rbacGroups, _, _, err := client.Repositories.GetContents(context.Background(), "ministryofjustice", "cloud-platform-environments", nsPath, nil)
// 	if err != nil {
// 		return err
// 	}

// 	fmt.Println(rbacGroups)

// 	return err
// }

// GetAllNamespaces takes the host endpoint for the how-out-of-date-are-we and
// returns a report of namespace details in the cluster.
func GetAllNamespaces(host *string) (namespaces AllNamespaces, err error) {
	client := &http.Client{
		Timeout: time.Second * 2,
	}

	req, err := http.NewRequest(http.MethodGet, *host, nil)
	if err != nil {
		return
	}

	req.Header.Add("User-Agent", "environments-namespace-pkg")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return
	}

	err = json.Unmarshal(body, &namespaces)
	if err != nil {
		return
	}

	return
}

// ChangedInPR takes a GitHub branch reference (usually provided by a GitHub Action), a
// personal access token with Read org permissions, the name of a repository and the owner.
// It queries the GitHub API for all changes made in a PR. If the PR contains changes to a namespace
// it returns a deduplicated slice of namespace names.
func ChangedInPR(branchRef, token, repo, owner string) ([]string, error) {
	if token == "" {
		return nil, errors.New("You must have a valid GitHub token.")
	}

	client, err := authenticate.GitHubClient(token)
	if err != nil {
		return nil, err
	}

	// branchRef is expected in the format:
	// "refs/pull/<pull request number>/merge"
	// This is usually populated by a GitHub action.
	str := strings.Split(branchRef, "/")
	prId, err := strconv.Atoi(str[2])
	if err != nil {
		log.Fatalln(err)
	}

	repos, _, _ := client.PullRequests.ListFiles(context.Background(), owner, repo, prId, nil)

	var namespaceNames []string
	for _, repo := range repos {
		if strings.Contains(*repo.Filename, "live") {
			// namespaces filepaths are assumed to come in
			// the format: namespaces/live-1.cloud-platform.service.justice.gov.uk/<namespaceName>
			s := strings.Split(*repo.Filename, "/")
			namespaceNames = append(namespaceNames, s[2])
		}
	}

	return deduplicateList(namespaceNames), nil
}

// deduplicateList will simply take a slice of strings and
// return a deduplicated version.
func deduplicateList(s []string) (list []string) {
	keys := make(map[string]bool)

	for _, entry := range s {
		if _, value := keys[entry]; !value {
			keys[entry] = true
			list = append(list, entry)
		}
	}

	return
}
