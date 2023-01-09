package main

import (
	_ "embed"
	"encoding/csv"
	"fmt"
	"os"
	"path/filepath"
	"strings"

	"github.com/ministryofjustice/cloud-platform-go-library/client"
	"github.com/ministryofjustice/cloud-platform-go-library/namespace"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/util/homedir"
)

//go:embed circle-repos.txt
var repos string

const githubUrl = "https://github.com/"

type circleNamespace struct {
	Name         string
	Slack        string
	Email        string
	Secrets      []secret
	SourceCode   string
	IsProduction string
}

type secret struct {
	Name  string
	Key   string
	Value string
}

type repository struct {
	Name    string `json:"name"`
	Address string `json:"address"`
}

func main() {
	kubeconfig := filepath.Join(homedir.HomeDir(), ".kube", "config")

	kubeClient, err := client.NewKubeClientWithValues(kubeconfig, "arn:aws:eks:eu-west-2:754256621582:cluster/live")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	repoList := getListOfRepos(repos)
	fmt.Println(repoList)
	clusterNamespaces, err := getClusterNamespaces(*kubeClient)
	if err != nil {
		fmt.Println(err)

		os.Exit(1)
	}

	list, err := whatsTheNamespace(repoList, clusterNamespaces)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// Write out all list names in a file
	if err := printToFile(list); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func printToFile(circleNamespaces []circleNamespace) error {
	f, err := os.Create("circle_namespaces.csv")
	if err != nil {
		return err
	}
	defer f.Close()

	w := csv.NewWriter(f)
	defer w.Flush()
	if err := w.Write([]string{"Namespace", "Slack", "Email", "SourceCode", "IsProduction"}); err != nil {
		return err
	}
	for _, ns := range circleNamespaces {
		if err := w.Write([]string{ns.Name, ns.Slack, ns.Email, ns.SourceCode, ns.IsProduction}); err != nil {
			return err
		}
	}
	return nil
}

func whatsTheNamespace(repoList []repository, clusterNamespaces *v1.NamespaceList) ([]circleNamespace, error) {
	var list []circleNamespace
	for _, repo := range repoList {
		fmt.Println("---")
		fmt.Println("Checking:", repo.Name)
		for _, ns := range clusterNamespaces.Items {
			if repo.Address == ns.Annotations["cloud-platform.justice.gov.uk/source-code"] {
				fmt.Println("Found:", ns.Name)
				fmt.Println(repo.Address, "is the same as", ns.Annotations["cloud-platform.justice.gov.uk/source-code"])
				ns := circleNamespace{
					Name:         ns.Name,
					Slack:        ns.Annotations["cloud-platform.justice.gov.uk/slack-channel"],
					Email:        ns.Annotations["cloud-platform.justice.gov.uk/owner"],
					SourceCode:   repo.Address,
					IsProduction: ns.Labels["cloud-platform.justice.gov.uk/is-production"],
				}
				list = append(list, ns)
			}
		}
	}
	return list, nil
}

func getClusterNamespaces(client client.KubeClient) (*v1.NamespaceList, error) {
	ns, err := namespace.AllNamespaces(&client)
	if err != nil {
		return nil, err
	}
	return ns, nil
}

func getListOfRepos(repos string) []repository {
	respositories := strings.Split(repos, "\n")

	var repoList []repository
	for _, repo := range respositories {
		r := repository{
			Name:    repo,
			Address: githubUrl + repo,
		}
		repoList = append(repoList, r)
	}

	return repoList
}
