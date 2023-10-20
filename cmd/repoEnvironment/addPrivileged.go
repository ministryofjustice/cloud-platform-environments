package main

import (
	"fmt"
	"html/template"
	"os"
	"path/filepath"
	"strings"

	cpCliUtils "github.com/ministryofjustice/cloud-platform-cli/pkg/util"
	"gopkg.in/yaml.v2"
)

func main() {

	home, _ := os.UserHomeDir()
	clusterDir := "namespaces/live.cloud-platform.service.justice.gov.uk/"
	gitRepo := "go/src/ministryofjustice/cloud-platform-environments"
	repoPath := filepath.Join(home, gitRepo, clusterDir)

	folders, err := cpCliUtils.ListFolderPaths(repoPath)
	if err != nil {
		panic(err)
	}

	var nsFolders []string
	nsFolders = append(nsFolders, folders[1:]...)
	for _, folder := range nsFolders {

		err := changeDir(folder)
		if err != nil {
			panic(err)
		}
		ns, err := getNamespaceDetails(folder)
		if err != nil {
			panic(err)
		}

		if ns.IsProduction != "true" {
			templatePath := filepath.Join(home, gitRepo, "cmd/repoEnvironment/template/pspPrivRoleBinding.tmpl")

			err := ns.CreateRbPSPPrivilegedFile(templatePath, "pspPrivRoleBinding.yaml")
			if err != nil {
				panic(err)
			}

		}

	}
}

func (ns *Namespace) CreateRbPSPPrivilegedFile(templatePath string, outputFile string) error {
	fmt.Println(templatePath)
	t, err := template.New("").Parse(templatePath)
	if err != nil {
		return err
	}

	f, err := os.Create(outputFile)
	if err != nil {
		return err
	}

	err = t.Execute(f, &ns)
	if err != nil {
		return err
	}
	return nil
}
func changeDir(folder string) error {
	if _, err := os.Stat(folder); os.IsNotExist(err) {
		fmt.Printf("Namespace %s does not exist, skipping \n", folder)
	}

	namespace := folder[strings.LastIndex(folder, ",")+1:]

	fmt.Println(namespace)

	if err := os.Chdir(filepath.Join(namespace)); err != nil {
		return err
	}
	return nil
}

func getNamespaceDetails(folder string) (*Namespace, error) {

	ns := Namespace{
		Namespace: folder,
	}

	err := ns.ReadNamespaceYaml()
	if err != nil {
		return nil, nil
	}
	return &ns, nil
}

const NamespaceYamlFile = "00-namespace.yaml"

type Namespace struct {
	Application           string `yaml:"application"`
	BusinessUnit          string `yaml:"businessUnit"`
	Environment           string `yaml:"environment"`
	GithubTeam            string `yaml:"githubTeam"`
	InfrastructureSupport string `yaml:"infrastructureSupport"`
	IsProduction          string `yaml:"isProduction"`
	Namespace             string `yaml:"namespace"`
	Owner                 string `yaml:"owner"`
	OwnerEmail            string `yaml:"ownerEmail"`
	SlackChannel          string `yaml:"slackChannel"`
	SourceCode            string `yaml:"sourceCode"`
}

// This is a public function so that we can use it in our tests
func (ns *Namespace) ReadNamespaceYaml() error {
	return ns.readNamespaceYamlFile(NamespaceYamlFile)
}

func (ns *Namespace) readNamespaceYamlFile(filename string) error {
	contents, err := os.ReadFile(filename)
	if err != nil {
		fmt.Printf("Failed to read namespace YAML file: %s", filename)
		return err
	}
	err = ns.parseNamespaceYaml(contents)
	if err != nil {
		fmt.Printf("Failed to parse namespace YAML file: %s", filename)
		return err
	}
	return nil
}

func (ns *Namespace) parseNamespaceYaml(yamlData []byte) error {
	type envNamespace struct {
		APIVersion string `yaml:"apiVersion"`
		Kind       string `yaml:"kind"`
		Metadata   struct {
			Namespace string `yaml:"name"`
			Labels    struct {
				IsProduction string `yaml:"cloud-platform.justice.gov.uk/is-production"`
				Environment  string `yaml:"cloud-platform.justice.gov.uk/environment-name"`
			} `yaml:"labels"`
			Annotations struct {
				BusinessUnit string `yaml:"cloud-platform.justice.gov.uk/business-unit"`
				Application  string `yaml:"cloud-platform.justice.gov.uk/application"`
				Owner        string `yaml:"cloud-platform.justice.gov.uk/owner"`
				SourceCode   string `yaml:"cloud-platform.justice.gov.uk/source-code"`
			} `yaml:"annotations"`
		} `yaml:"metadata"`
	}

	t := envNamespace{}

	err := yaml.Unmarshal(yamlData, &t)
	if err != nil {
		fmt.Printf("Could not decode namespace YAML: %v", err)
		return err
	}

	ns.Application = t.Metadata.Annotations.Application
	ns.BusinessUnit = t.Metadata.Annotations.BusinessUnit
	ns.Environment = t.Metadata.Labels.Environment
	ns.IsProduction = t.Metadata.Labels.IsProduction
	ns.Namespace = t.Metadata.Namespace
	ns.Owner = t.Metadata.Annotations.Owner
	ns.SourceCode = t.Metadata.Annotations.SourceCode
	return nil
}
