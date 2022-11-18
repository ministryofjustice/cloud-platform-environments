package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"path/filepath"

	"github.com/google/go-github/github"
	"github.com/nikoksr/notify"
	"github.com/nikoksr/notify/service/slack"
	"golang.org/x/oauth2"
	metav1 "k8s.io/apimachinery/pkg/apis/meta/v1"
	"k8s.io/apimachinery/pkg/util/sets"
	"k8s.io/client-go/kubernetes"
	"k8s.io/client-go/tools/clientcmd"
	"k8s.io/client-go/util/homedir"
)

type KubernetesClient struct {
	client *kubernetes.Interface
}

func main() {
	// list of excluded Namespaces
	excludedNamespaces := []string{
		"cert-manager",
		"default",
		"ingress-controllers",
		"kube-node-lease",
		"kube-public",
		"kube-system",
		"kuberhealthy",
		"kuberos",
		"logging",
		"opa",
		"overprovision",
		"velero",
	}

	// get arguments from the user
	var kubeconfig *string
	if home := homedir.HomeDir(); home != "" {
		kubeconfig = flag.String("kubeconfig", filepath.Join(home, ".kube", "config"), "(optional) absolute path to the kubeconfig file")
	} else {
		kubeconfig = flag.String("kubeconfig", "", "absolute path to the kubeconfig file")
	}
	tok := flag.String("p", "", "github token")
	slackApi := flag.String("slackApi", "", "api token for slack")
	channelId := flag.String("channelId", "", "channel id for slack")

	flag.Parse()

	// create clients
	kubeClient, gitHubClient, err := createClients(*kubeconfig, *tok)
	if err != nil {
		log.Fatal(err)
	}

	// get all cluster namespaces
	clusterNamespaces, err := getClusterNamespaces(kubeClient)
	if err != nil {
		log.Fatal(err)
	}

	// get all github namespaces
	githubNamespaces, err := getGithubNamespaces(gitHubClient)
	if err != nil {
		log.Fatal(err)
	}

	// compare namespaces and print out differences
	fmt.Println("Namespaces in cluster but not in github:")
	for _, ns := range clusterNamespaces {
		if !sets.NewString(githubNamespaces...).Has(ns) && !sets.NewString(excludedNamespaces...).Has(ns) {
			fmt.Println(ns)
		}
	}

	if *slackApi != "" {
		notifier := notify.New()
		slackSvc := slack.New(*slackApi)
		if err != nil {
			log.Fatal(err)
		}

		slackSvc.AddReceivers(*channelId)
		notifier.UseServices(slackSvc)

		_ = notifier.Send(context.TODO(), "Namespaces in cluster but not in github:", fmt.Sprintf("%v", clusterNamespaces))
	}
}

// getClusterNamespaces returns a set of namespaces in the cluster
func getClusterNamespaces(client kubernetes.Interface) ([]string, error) {
	namespaces, err := client.CoreV1().Namespaces().List(context.TODO(), metav1.ListOptions{})
	if err != nil {
		return nil, err
	}

	nsSet := sets.NewString()
	for _, ns := range namespaces.Items {
		nsSet.Insert(ns.Name)
	}
	return nsSet.List(), nil
}

// getGithubNamespaces returns a set of namespaces in githubToken
func getGithubNamespaces(client *github.Client) ([]string, error) {
	// get the list of all directories in https://github.com/ministryofjustice/cloud-platform-environments/namespaces
	opt := &github.RepositoryContentGetOptions{Ref: "main"}
	_, dir, _, err := client.Repositories.GetContents(context.TODO(), "ministryofjustice", "cloud-platform-environments", "namespaces/live.cloud-platform.service.justice.gov.uk", opt)
	if err != nil {
		return nil, err
	}

	nsSet := sets.NewString()
	for _, d := range dir {
		nsSet.Insert(*d.Name)
	}
	return nsSet.List(), nil
}

func createClients(kubeconfig, githubToken string) (kubernetes.Interface, *github.Client, error) {
	// create kube client
	kubeClient, err := createKubeClient(kubeconfig)
	if err != nil {
		return nil, nil, err
	}

	// create github client
	gitHubClient, err := createGitHubClient(githubToken)
	if err != nil {
		return nil, nil, err
	}

	return kubeClient, gitHubClient, nil
}

func createGitHubClient(pass string) (*github.Client, error) {
	if pass == "" {
		return nil, fmt.Errorf("no github token provided")
	}
	ctx := context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: pass},
	)
	tc := oauth2.NewClient(ctx, ts)

	client := github.NewClient(tc)
	return client, nil
}

func createKubeClient(kubeconfig string) (kubernetes.Interface, error) {
	// use the current context in kubeconfig
	config, err := clientcmd.BuildConfigFromFlags("", kubeconfig)
	if err != nil {
		return nil, err
	}

	// create the clientset
	return kubernetes.NewForConfig(config)
}
