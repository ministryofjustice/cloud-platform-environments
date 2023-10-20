package namespace

import (
	"fmt"
	"os"
	"strings"

	"gopkg.in/yaml.v2"
)

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
	ns.OwnerEmail = strings.Split(t.Metadata.Annotations.Owner, ": ")[1]
	ns.SourceCode = t.Metadata.Annotations.SourceCode
	return nil
}
