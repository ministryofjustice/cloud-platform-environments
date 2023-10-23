package app

import (
	"fmt"
	"html/template"
	"log"
	"os"

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
	ReviewAfter           string `yaml:"reviewAfter"`
}

func GetNamespaceDetails(folder string) (*Namespace, error) {
	ns := Namespace{}
	namespaceYamlPath := fmt.Sprintf("%s/%s", folder, NamespaceYamlFile)
	err := ns.readNamespaceYamlFile(namespaceYamlPath)
	if err != nil {
		return &ns, err
	}
	return &ns, nil
}

func (ns *Namespace) CreateRbPSPPrivilegedFile(templatePath string, outputFile string) error {
	content, err := os.ReadFile(templatePath)
	if err != nil {
		log.Fatalf("unable to read file: %v", err)
	}
	t, err := template.New("").Parse(string(content))
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

func (ns *Namespace) readNamespaceYamlFile(filename string) error {
	contents, err := os.ReadFile(filename)
	if err != nil {
		fmt.Printf("Failed to read namespace YAML file: %s", filename)
		return nil
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
				SlackChannel string `yaml:"cloud-platform.justice.gov.uk/slack-channel"`
				Application  string `yaml:"cloud-platform.justice.gov.uk/application"`
				Owner        string `yaml:"cloud-platform.justice.gov.uk/owner"`
				SourceCode   string `yaml:"cloud-platform.justice.gov.uk/source-code"`
				ReviewAfter  string `yaml:"cloud-platform.justice.gov.uk/review-after"`
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
	ns.SlackChannel = t.Metadata.Annotations.SlackChannel
	ns.Environment = t.Metadata.Labels.Environment
	ns.IsProduction = t.Metadata.Labels.IsProduction
	ns.Namespace = t.Metadata.Namespace
	ns.Owner = t.Metadata.Annotations.Owner
	ns.SourceCode = t.Metadata.Annotations.SourceCode
	return nil
}
