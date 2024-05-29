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

type Team struct {
	Name string `json:"team"`
}

type PRFile struct {
	Filename string `json:"filename"`
	RawURL   string `json:"raw_url"`
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

func TeamExists(teamname string, teams []Team) bool {
	for _, team := range teams {
		if team.Name == teamname {
			return true
		}
	}
	return false
}

func IsRepoPublic(repo string, token string) (bool, error) {
	if repo == "" {
		return false, errors.New("sourcecoderepo annotations is empty")
	}

	url := "https://github.com/ministryofjustice/" + repo
	req, err := http.NewRequest("Get", url, nil)
	if err != nil {
		return false, err
	}

	req.Header.Set("Authorization", "token "+token)

	client := &http.Client{}

	resp, err := client.Do(req)
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

func validateAnnotations(data []byte, teams []Team, token string) (bool, string) {
	config, err := LoadConfig(data)
	if err != nil {
		return false, err.Error()
	}

	if config.Kind != "Namespace" {
		return true, "Skipping: not a namespace"
	}

	if !TeamExists(config.Metadata.Annotations["cloud-platform.justice.gov.uk/team-name"], teams) {
		return false, "Team doesn't exist"
	}

	isPublic, err := IsRepoPublic(config.Metadata.Annotations["cloud-platform.justice.gov.uk/source-code"], token)
	if err != nil {
		return false, err.Error()
	}
	if !isPublic {
		return false, "Repo is either private or does not exist."
	}

	return true, "Validation successful"
}

func fetchPRFiles(owner, repo, prNumber, token string) ([]PRFile, error) {
	url := fmt.Sprintf("https://api.github.com/repos/%s/%s/pulls/%s/files", owner, repo, prNumber)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "toke "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("Github API responded with status code: %d", resp.StatusCode)
	}

	var files []PRFile
	err = json.NewDecoder(resp.Body).Decode(&files)
	if err != nil {
		return nil, err
	}

	return files, nil
}

func fetchTeams(owner, token string) ([]Team, error) {
	url := fmt.Sprintf("https://api.github.com/orgs/%s/teams", owner)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Authorization", "token "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("GitHub API responded with status code: %d", resp.StatusCode)
	}

	var teams []Team
	err = json.NewDecoder(resp.Body).Decode(&teams)
	if err != nil {
		return nil, err
	}

	return teams, nil
}

func validateRemoteFile(url, token string, teams []Team) (bool, string) {
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return false, err.Error()
	}
	req.Header.Set("Authorization", "token "+token)

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return false, err.Error()
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return false, fmt.Sprintf("Failed to fetch file: %s", resp.Status)
	}

	data, err := io.ReadAll(resp.Body)
	if err != nil {
		return false, err.Error()
	}

	return validateAnnotations(data, teams, token)
}
