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
	"github.com/ministryofjustice/cloud-platform-how-out-of-date-are-we/reports/pkg/hoodaw"
	"gopkg.in/yaml.v2"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/kubernetes"

	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/metrics/pkg/apis/metrics/v1beta1"
	"k8s.io/metrics/pkg/client/clientset/versioned"
)

// Namespace describes a Cloud Platform namespace object.
type Namespace struct {
	Application      string
	BusinessUnit     string
	DeploymentType   string
	IsProduction     bool
	Cluster          string
	DomainNames      []string
	GithubURL        string
	Name             string
	RbacTeam         []string
	TeamName         string
	TeamSlackChannel string
}

// AllNamespaces contains the json to go struct of the hosted_services endpoint.
type AllNamespaces struct {
	Namespaces []Namespace `json:"namespace_details"`
}

// RbacFile describes the rbac file in a users namespace
type RbacFile struct {
	Metadata struct {
		Name      string `yaml:"name"`
		Namespace string `yaml:"namespace"`
	} `yaml:"metadata"`
	Subjects []struct {
		Kind     string `yaml:"kind"`
		Name     string `yaml:"name"`
		APIGroup string `yaml:"apiGroup"`
	} `yaml:"subjects"`
}

// org and envRepo contain the GitHub user and repository respectively. They shouldn't ever change.
const (
	org     = "ministryofjustice"
	envRepo = "cloud-platform-environments"
)

// GetNamespace takes the name of a namespace as a string and returns
// a Namespace data type.
func GetNamespace(s string, endpoint string) (Namespace, error) {
	var namespace Namespace

	allNamespaces, err := GetAllNamespacesFromHoodaw(endpoint)
	if err != nil {
		return namespace, err
	}

	for _, ns := range allNamespaces.Namespaces {
		if s == ns.Name {
			return ns, nil
		}
	}

	return namespace, fmt.Errorf("namespace %s is not found in the cluster", s)
}

// GetProductionNamespaces takes a type of AllNamespaces and
// returns a slice of all production namespaces in all clusters.
// AllNamespaces is generated by the GetAllNamespaces function.
func GetProductionNamespaces(ns AllNamespaces) (namespaces []string, err error) {
	if len(ns.Namespaces) == 0 {
		return nil, errors.New("no namespaces found")
	}

	for _, ns := range ns.Namespaces {
		if ns.IsProduction == true {
			namespaces = append(namespaces, ns.Name)
		}
	}

	return
}

// GetNonProductionNamespaces takes a type of AllNamespaces and
// returns a slice of all production namespaces in all clusters.
// AllNamespaces is generated by the GetAllNamespaces function.
func GetNonProductionNamespaces(ns AllNamespaces) (namespaces []string, err error) {
	if len(ns.Namespaces) == 0 {
		return nil, errors.New("no namespaces found")
	}

	for _, ns := range ns.Namespaces {
		if ns.IsProduction == false {
			namespaces = append(namespaces, ns.Name)
		}
	}

	return
}

// GetAllNamespacesFromHoodaw queries the host endpoint for the how-out-of-date-are-we, Unmarshal
// the response json and return all namespaces
// returns a report of namespace details .
func GetAllNamespacesFromHoodaw(endPoint string) (namespaces AllNamespaces, err error) {
	body, err := hoodaw.QueryApi(endPoint)
	if err != nil {
		return
	}

	err = json.Unmarshal(body, &namespaces)
	if err != nil {
		return
	}

	return
}

// GetAllNamespacesFromCluster takes a Kubernetes clientset and returns all namespaces in the cluster
// with type v1.Namespace
func GetAllNamespacesFromCluster(clientSet *kubernetes.Clientset) ([]v1.Namespace, error) {

	namespaces, err := clientSet.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("can't list namespaces from cluster %s", err.Error())
	}

	return namespaces.Items, nil
}

// GetAllPodsFromCluster takes a Kubernetes clientset and returns all pods in all namespaces for a
// given cluster with type v1.PodList
func GetAllPodsFromCluster(clientSet kubernetes.Interface) ([]v1.Pod, error) {

	pods, err := clientSet.CoreV1().Pods("").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("can't list pods from cluster %s", err.Error())
	}

	return pods.Items, nil
}

// GetAllPodMetricsesFromCluster takes a Kubernetes clientset and returns all pods Metrics
// in all namespaces for a given cluster with type v1beta1.PodMetrics
func GetAllPodMetricsesFromCluster(mclientSet versioned.Interface) ([]v1beta1.PodMetrics, error) {

	podMetricsList, err := mclientSet.MetricsV1beta1().PodMetricses("").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("can't get Pod Metrics from cluster %s", err.Error())
	}
	return podMetricsList.Items, nil

}

// GetAllPodsFromCluster takes a Kubernetes clientset and returns all pods in all namespaces for a
// given cluster with type v1.PodList
func GetAllResourceQuotasFromCluster(clientSet kubernetes.Interface) ([]v1.ResourceQuota, error) {

	resourcequotas, err := clientSet.CoreV1().ResourceQuotas("").List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, fmt.Errorf("can't list resourcequotas from cluster %s", err.Error())
	}

	return resourcequotas.Items, nil
}

// SetRbacTeam takes a cluster name as a string in the format of `live` (for example) and sets the
// method value `RbacTeam`.
// The function performs a HTTP GET request to GitHub, grabs the contents of the rbac yaml file and
// interpolates the GitHub teams allowed to access a namespace.
func (ns *Namespace) SetRbacTeam(cluster string) error {
	client := &http.Client{
		Timeout: time.Second * 2,
	}

	// It is assumed the rbac file will remain constant.
	host := fmt.Sprintf("https://raw.githubusercontent.com/%s/%s/main/namespaces/%s.cloud-platform.service.justice.gov.uk/%s/01-rbac.yaml", org, envRepo, cluster, ns.Name)

	req, err := http.NewRequest(http.MethodGet, host, nil)
	if err != nil {
		return err
	}

	req.Header.Add("User-Agent", "moj-env-namespace-pkg")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return err
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return err
	}

	rbac := RbacFile{}

	err = yaml.Unmarshal(body, &rbac)
	if err != nil {
		return err
	}

	for _, team := range rbac.Subjects {
		if strings.Contains(team.Name, "github:") {
			name := strings.Split(team.Name, ":")
			ns.RbacTeam = append(ns.RbacTeam, name[1])
		}
	}

	if ns.RbacTeam == nil {
		return fmt.Errorf("unable to find team names for %s", ns.Name)
	}

	return nil
}

// ChangedInPR takes a GitHub branch reference (usually provided by a GitHub Action), a
// personal access token with Read org permissions, the name of a repository and the owner.
// It queries the GitHub API for all changes made in a PR. If the PR contains changes to a namespace
// it returns a deduplicated slice of namespace names.
func ChangedInPR(branchRef, token, repo, owner string) ([]string, error) {
	if token == "" {
		return nil, errors.New("you must have a valid GitHub token")
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
			// the format: namespaces/live.cloud-platform.service.justice.gov.uk/<namespaceName>
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
