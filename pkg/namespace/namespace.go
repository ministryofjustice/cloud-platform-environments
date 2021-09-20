// package namespace contains required code to interact with a Cloud Platform namespace.
package namespace

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/authenticate"
)

// Namespace describes a Cloud Platform namespace object.
type Namespace struct {
	Application      string        `json:"application"`
	BusinessUnit     string        `json:"business_unit"`
	DeploymentType   string        `json:"deployment_type"`
	Cluster          string        `json:"cluster,omitempty"`
	DomainNames      []interface{} `json:"domain_names"`
	GithubURL        string        `json:"github_url"`
	Name             string        `json:"namespace"`
	RbacTeam         string        `json:"rbac_team,omitempty"`
	TeamName         string        `json:"team_name"`
	TeamSlackChannel string        `json:"team_slack_channel"`
}

// AllNamespaces contains the json to go struct of the hosted_services endpoint.
type AllNamespaces struct {
	Namespaces []Namespace `json:"namespace_details"`
}

// GetNamespace takes the name of a namespace as a string and returns
// a Namespace data type.
func GetNamespace(s string) (Namespace, error) {
	var namespace Namespace
	host := "https://reports.service.justice.gov.uk/hosted_services"

	allNamespaces, err := GetAllNamespaces(&host)
	if err != nil {
		return namespace, err
	}

	for _, ns := range allNamespaces.Namespaces {
		if s == ns.Name {
			return ns, nil
		}
	}

	return namespace, fmt.Errorf("Namespace %s is not found in the cluster.", s)
}

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
