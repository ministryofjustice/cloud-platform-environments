package main

import (
	_ "embed"
	"flag"
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

const githubUrl = "https://github.com/ministryofjustice/"

type repository struct {
	Name    string `json:"name"`
	Address string `json:"address"`
}

func main() {
	var kubeconfig *string
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", os.Getenv("KUBECONFIG"), "absolute path to the kubeconfig file")
	}

	repoList := getListOfRepos(repos)
	kubeClient, err := client.NewKubeClientWithValues(*kubeconfig, "arn:aws:eks:eu-west-2:754256621582:cluster/live")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
	clusterNamespaces, err := getClusterNamespaces(*kubeClient)
	if err != nil {
		fmt.Println(err)

		os.Exit(1)
	}

	list, err := aCircleNamespace(repoList, clusterNamespaces)
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	// Write out all list names in a file
	if err := printToFile(removeDuplicates(list)); err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}

func printToFile(list []string) error {
	f, err := os.Create("circle-ns.txt")
	if err != nil {
		return err
	}
	defer f.Close()

	for _, repo := range list {
		_, err := f.WriteString(repo + "\n")
		if err != nil {
			return err
		}
	}
	return nil
}

func aCircleNamespace(repoList []repository, clusterNamespaces *v1.NamespaceList) ([]string, error) {
	var list []string
	for _, repo := range repoList {
		fmt.Println(repo.Name)
		fmt.Println("---")
		for _, ns := range clusterNamespaces.Items {
			if repo.Address == ns.Annotations["cloud-platform.justice.gov.uk/source-code"] {
				fmt.Println(repo.Address, "matches", ns.Annotations["cloud-platform.justice.gov.uk/source-code"], "in", ns.Name)
				list = append(list, ns.Name)
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

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func removeDuplicates(strList []string) []string {
	list := []string{}
	for _, item := range strList {
		if contains(list, item) == false {
			list = append(list, item)
		}
	}
	return list
}
