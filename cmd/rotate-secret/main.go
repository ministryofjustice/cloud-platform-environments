package main

import (
	"context"
	_ "embed"
	"encoding/csv"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"

	"github.com/hashicorp/go-version"
	install "github.com/hashicorp/hc-install"
	"github.com/hashicorp/hc-install/fs"
	"github.com/hashicorp/hc-install/product"
	"github.com/hashicorp/hc-install/releases"
	"github.com/hashicorp/hc-install/src"
	"github.com/hashicorp/terraform-exec/tfexec"
)

type Namespace struct {
	Name      string
	Secrets   []Secret
	FilePath  string
	IsTainted bool
}

type Secret struct {
	value        string
	stateAddress string
}

//go:embed circle_namespaces.txt
var circleNamespaces string

const (
	namespacePrefix = "../../namespaces/live.cloud-platform.service.justice.gov.uk"
)

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

func main() {
	// identify the namespace
	namespaces := strings.Split(strings.TrimSpace(circleNamespaces), "\n")
	if err := ensureEnvVarsSet(); err != nil {
		log.Fatal(err)
	}

	exec, err := setupTerraform()
	if err != nil {
		log.Fatal(err)
	}

	// get current directory
	var listNamespaces []Namespace
	for _, ns := range namespaces {
		fmt.Println(ns)
		namespace := NewNamespace(ns)

		if err := namespace.GetListOfSecrets(exec); err != nil {
			fmt.Printf("error getting list of secrets: %v", err)
			os.Exit(1)
		}

		if err := namespace.RotateSecrets(exec); err != nil {
			fmt.Printf("error rotating secrets: %v", err)
			os.Exit(1)
		}

		namespace.IsTainted = true

		listNamespaces = append(listNamespaces, namespace)
	}

	f, err := os.Create("tainted_circle_namespaces.csv")
	if err != nil {
		log.Fatal(err)
		os.Exit(1)
	}
	defer f.Close()

	for _, ns := range listNamespaces {
		if err := printToFile(ns, f.Name()); err != nil {
			fmt.Printf("error writing to file: %v", err)
			os.Exit(1)
		}
	}
}

func printToFile(ns Namespace, fname string) error {
	f, err := os.OpenFile(fname, os.O_WRONLY|os.O_CREATE|os.O_APPEND, 0644)
	if err != nil {
		return err
	}

	w := csv.NewWriter(f)
	defer w.Flush()
	if err := w.Write([]string{"Namespace", "ResourceAddress", "AccessKeys", "Successful"}); err != nil {
		return err
	}

	for _, secret := range ns.Secrets {
		if err := w.Write([]string{ns.Name, secret.stateAddress, secret.value, strconv.FormatBool(ns.IsTainted)}); err != nil {
			return err
		}
	}
	return nil
}
func ensureEnvVarsSet() error {
	if err := os.Setenv("TF_VAR_cluster_name", "live"); err != nil {
		return err
	}
	if err := os.Setenv("TF_VAR_cluster_state_bucket", "cloud-platform-terraform-state"); err != nil {
		return err
	}
	if err := os.Setenv("TF_VAR_kubernetes_cluster", "DF366E49809688A3B16EEC29707D8C09.gr7.eu-west-2.eks.amazonaws.com"); err != nil {
		return err
	}
	if err := os.Setenv("KUBE_CONFIG_PATH", "${HOME}/.kube/config"); err != nil {
		return err
	}
	if err := os.Setenv("TF_VAR_eks_cluster_name", "live"); err != nil {
		return err
	}
	if err := os.Setenv("TF_VAR_vpc_name", "live-1"); err != nil {
		return err
	}

	return nil
}

func (ns *Namespace) RotateSecrets(exec string) error {
	tf, err := tfexec.NewTerraform(ns.FilePath+"/resources", exec)
	if err != nil {
		return err
	}

	tf.SetStdout(os.Stdout)
	tf.SetStderr(os.Stderr)

	for _, secret := range ns.Secrets {
		if err := tf.Taint(context.Background(), secret.stateAddress); err != nil {
			return err
		}
	}

	return nil
}

func (ns *Namespace) GetListOfSecrets(exec string) error {
	tf, err := tfexec.NewTerraform(ns.FilePath+"/resources", exec)
	if err != nil {
		return err
	}

	tf.SetStdout(os.Stdout)
	tf.SetStderr(os.Stderr)

	err = tf.Init(context.Background(),
		tfexec.BackendConfig("bucket=cloud-platform-terraform-state"),
		tfexec.BackendConfig("key=cloud-platform-environments/live-1.cloud-platform.service.justice.gov.uk/"+ns.Name+"/terraform.tfstate"),
		tfexec.BackendConfig("region=eu-west-1"),
		tfexec.BackendConfig("dynamodb_table=cloud-platform-environments-terraform-lock"),
	)
	if err != nil {
		log.Fatalf("error running Init: %s", err)
	}

	tf.SetStdout(nil)
	state, err := tf.Show(context.Background())
	if err != nil {
		log.Fatalf("error running Show: %s", err)
	}

	if state.Values == nil {
		log.Println("no state values found for namespace: ", ns.Name)
		return nil
	}

	for _, resource := range state.Values.RootModule.Resources {
		if strings.Contains(resource.Address, "aws_iam_access_key") && !strings.Contains(resource.Address, "key_2023") {
			secret := NewSecret(resource.Address)
			for key, value := range resource.AttributeValues {
				if key == "id" {
					secret.value = fmt.Sprintf("%v", value)
				}
			}

			ns.Secrets = append(ns.Secrets, secret)
		}
	}

	for _, childResources := range state.Values.RootModule.ChildModules {
		for _, modules := range childResources.Resources {
			if strings.Contains(modules.Address, "aws_iam_access_key") && !strings.Contains(modules.Address, "key_2023") {
				secret := NewSecret(modules.Address)
				for key, value := range modules.AttributeValues {
					if key == "id" {
						secret.value = fmt.Sprintf("%v", value)
					}
				}

				ns.Secrets = append(ns.Secrets, secret)
			}
		}
	}

	return nil
}

func NewSecret(name string) Secret {
	return Secret{
		stateAddress: name,
	}
}

func NewNamespace(name string) Namespace {
	return Namespace{
		Name:     name,
		FilePath: fmt.Sprintf("%s/%s", namespacePrefix, name),
	}
}
