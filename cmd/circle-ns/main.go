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

	// get all cluster namespaces
	fmt.Println(clusterNamespaces)
	fmt.Println(repoList)
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
