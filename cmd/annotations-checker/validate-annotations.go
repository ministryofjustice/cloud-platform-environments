package main

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"

	"gopkg.in/yaml.v2"
)

type Metadata struct {
	Annotations map[string]string `yaml:"annotations"`
}

type FullConfig struct {
	Kind     string   `yaml:"kind"`
	Metadata Metadata `yaml:"metadata"`
}

func LoadConfig(filePath string) (*FullConfig, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, err
	}
	defer file.Close()

	data, err := io.ReadAll(file)
	if err != nil {
		return nil, err
	}

	var config FullConfig
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		return nil, err
	}

	return &config, nil
}

func TeamExists(teamname string) bool {
	organizationTeams := []string{"hmpps-sre", "cloud-platform", "laa"}
	for _, team := range organizationTeams {
		if team == teamname {
			return true
		}
	}
	return false
}

func IsRepoPublic(repo string) (bool, error) {
	if repo == "" {
		return false, errors.New("sourcecoderepo annotations is empty")
	}

	url := "https://github.com/ministryofjustice/" + repo
	resp, err := http.Get(url)
	if err != nil {
		return false, err
	}
	defer resp.Body.Close()

	if resp.StatusCode == http.StatusNotFound {
		return false, errors.New("repo does not exist")
	}

	if resp.StatusCode != http.StatusOK {
		return false, fmt.Errorf("error checking repo's visibility: %s", resp.Status)
	}

	var result struct {
		Private bool `json:"private"`
	}
	err = json.NewDecoder(resp.Body).Decode(&result)
	if err != nil {
		return false, err
	}

	return !result.Private, nil
}

func validateAnnotations(filePath string) (bool, string) {
	config, err := LoadConfig(filePath)
	if err != nil {
		return false, err.Error()
	}

	if config.Kind != "Namespace" {
		return true, "Skipping: not a namespace"
	}

	if !TeamExists(config.Metadata.Annotations["cloud-platform.justice.gov.uk/team-name"]) {
		return false, "Team doesn't exist"
	}

	isPublic, err := IsRepoPublic(config.Metadata.Annotations["cloud-platform.justice.gov.uk/source-code"])
	if err != nil {
		return false, err.Error()
	}
	if !isPublic {
		return false, "Repo is either private or does not exist."
	}

	return true, "Validation successful"
}
