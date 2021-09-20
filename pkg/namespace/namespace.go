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

// HoodawReport contains the json to go struct of the hosted_services endpoint.
type HoodawReport struct {
	NamespaceDetails []struct {
		Namespace        string        `json:"namespace"`
		Application      string        `json:"application"`
		BusinessUnit     string        `json:"business_unit"`
		TeamName         string        `json:"team_name"`
		TeamSlackChannel string        `json:"team_slack_channel"`
		GithubURL        string        `json:"github_url"`
		DeploymentType   string        `json:"deployment_type"`
		DomainNames      []interface{} `json:"domain_names"`
	} `json:"namespace_details"`
}

// GetAllNamespaces takes the host endpoint for the how-out-of-date-are-we and
// returns a report of namespace details in the cluster.
func GetAllNamespaces(host *string) (*HoodawReport, error) {
	client := &http.Client{
		Timeout: time.Second * 2,
	}

	req, err := http.NewRequest("GET", *host, nil)
	if err != nil {
		return nil, err
	}

	req.Header.Add("User-Agent", "environments-namespace-pkg")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	namespaces := &HoodawReport{}

	err = json.Unmarshal(body, &namespaces)
	if err != nil {
		return nil, err
	}

	return namespaces, nil
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
