package main

import (
	"context"
	_ "embed"
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/fatih/color"
	"github.com/hashicorp/go-version"
	install "github.com/hashicorp/hc-install"
	"github.com/hashicorp/hc-install/fs"
	"github.com/hashicorp/hc-install/product"
	"github.com/hashicorp/hc-install/releases"
	"github.com/hashicorp/hc-install/src"
	"github.com/hashicorp/terraform-exec/tfexec"
	"github.com/ministryofjustice/cloud-platform-go-library/client"
	"github.com/ministryofjustice/cloud-platform-go-library/namespace"
	v1 "k8s.io/api/core/v1"
	"k8s.io/client-go/util/homedir"
)

//go:embed circleci-namespaces.txt
var circleciNamespaces string

const (
	namespacePrefix = "../../namespaces/live.cloud-platform.service.justice.gov.uk"
)

type cpNamespace struct {
	filePath    string
	ignored     bool
	name        string
	owner       string
	pods        int
	resource    []string
	slackRoom   string
	isProd      string
	environment string
}

func main() {
	// take in list of circle namespaces
	circleciNamespaces := strings.Split(strings.TrimSpace(circleciNamespaces), "\n")

	kubeconfig := filepath.Join(homedir.HomeDir(), ".kube", "config")

	kubeClient, err := client.NewKubeClientWithValues(kubeconfig, "arn:aws:eks:eu-west-2:754256621582:cluster/live")
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}

	exec, err := setupTerraform()
	if err != nil {
		log.Fatal(err)
	}

	clusterNamespaces, err := getClusterNamespaces(*kubeClient)
	if err != nil {
		fmt.Println(err)

		os.Exit(1)
	}

	// compare circle namespaces to cluster namespaces
	// if circle namespace is not in cluster namespaces, print it
	var phase3Namespaces []cpNamespace
	for _, ns := range clusterNamespaces.Items {
		if !contains(circleciNamespaces, ns.Name) && !strings.Contains(ns.Name, "kube-") {
			phase3Namespaces = append(phase3Namespaces, newNamespace(ns))
		}
	}
	var namespacesForTaint []cpNamespace
	for _, ns := range phase3Namespaces {

		color.Blue(ns.name)
		if ns.HasIam(exec) {
			namespacesForTaint = append(namespacesForTaint, ns)
		}
	}

	if err := printToFile(namespacesForTaint); err != nil {
		log.Fatal(err)
	}
	// find remaining namespaces, that don't equal system.
	// for each namespace
	// 		loop over and put namepsace in a list if it contains an IAM cred
	// 		write the namespaces in that list to a csv file.
}

func printToFile(namespaces []cpNamespace) error {
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
	for _, ns := range namespaces {
		if err := w.Write([]string{ns.name, ns.slackRoom, ns.owner, ns.isProd, ns.isProd}); err != nil {
			return err
		}
	}
	return nil
}

func (ns cpNamespace) HasIam(exec string) bool {
	tf, err := tfexec.NewTerraform(ns.filePath+"/resources", exec)
	if err != nil {
		log.Println(err)
		return false
	}
	// tf.SetStdout(os.Stdout)
	// tf.SetStderr(os.Stderr)

	err = tf.Init(context.Background(),
		tfexec.BackendConfig("bucket=cloud-platform-terraform-state"),
		tfexec.BackendConfig("key=cloud-platform-environments/live-1.cloud-platform.service.justice.gov.uk/"+ns.name+"/terraform.tfstate"),
		tfexec.BackendConfig("region=eu-west-1"),
		tfexec.BackendConfig("dynamodb_table=cloud-platform-environments-terraform-lock"),
	)
	// if it fails due to m1 issues, then rerun.
	if err != nil {
		err = tf.Init(context.Background(),
			tfexec.BackendConfig("bucket=cloud-platform-terraform-state"),
			tfexec.BackendConfig("key=cloud-platform-environments/live-1.cloud-platform.service.justice.gov.uk/"+ns.name+"/terraform.tfstate"),
			tfexec.BackendConfig("region=eu-west-1"),
			tfexec.BackendConfig("dynamodb_table=cloud-platform-environments-terraform-lock"),
		)
		if err != nil {
			return false
		}
	} else if err != nil {
		return false
	}

	tf.SetStdout(nil)
	state, err := tf.Show(context.Background())
	if err != nil {
		log.Println(err)
		return false
	}

	if state.Values == nil {
		log.Println("no state values found for namespace: ", ns.name)
		return false
	}

	for _, resource := range state.Values.RootModule.Resources {
		if strings.Contains(resource.Address, "aws_iam_access_key") && !strings.Contains(resource.Address, "key_2023") {
			return true
		}
	}

	for _, childResources := range state.Values.RootModule.ChildModules {
		for _, modules := range childResources.Resources {
			if strings.Contains(modules.Address, "aws_iam_access_key") && !strings.Contains(modules.Address, "key_2023") {
				return true
			}
		}
	}

	return false
}

func newNamespace(ns v1.Namespace) cpNamespace {
	cpNs := cpNamespace{
		name:     ns.Name,
		filePath: fmt.Sprintf("%s/%s", namespacePrefix, ns.Name),
	}
	//contact
	annotations := ns.GetAnnotations()
	for k, v := range annotations {
		switch k {
		case "cloud-platform.justice.gov.uk/slack-channel":
			cpNs.slackRoom = v
		case "cloud-platform.justice.gov.uk/owner":
			cpNs.owner = v
		}
	}

	labels := ns.GetLabels()
	for k, v := range labels {
		switch k {
		case "cloud-platform.justice.gov.uk/is-production":
			cpNs.isProd = v
		case "cloud-platform.justice.gov.uk/environment-name":
			cpNs.environment = v
		}
	}

	return cpNs
}

func contains(s []string, e string) bool {
	for _, a := range s {
		if a == e {
			return true
		}
	}
	return false
}

func getClusterNamespaces(client client.KubeClient) (*v1.NamespaceList, error) {
	ns, err := namespace.AllNamespaces(&client)
	if err != nil {
		return nil, err
	}
	return ns, nil
}

func setupTerraform() (string, error) {
	i := install.NewInstaller()
	v := version.Must(version.NewVersion("0.14.8"))
	execPath, err := i.Ensure(context.TODO(), []src.Source{
		&fs.ExactVersion{
			Product: product.Terraform,
			Version: v,
		},
		&releases.ExactVersion{
			Product: product.Terraform,
			Version: v,
		},
	})
	if err != nil {
		return "", err
	}

	defer func() {
		if err := i.Remove(context.TODO()); err != nil {
			return
		}
	}()

	return execPath, nil
}
