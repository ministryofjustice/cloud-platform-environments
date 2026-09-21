package utils

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"regexp"
	"strings"
)

type APIResponse struct {
	RepoName      string `json:"repo"`
	LatestVersion string `json:"currentVersion"`
	LatestSHA     string `json:"sha"`
}

func getHttpReq(apiURL, name string) ([]byte, error) {
	resp, err := http.Get(apiURL + name)

	if err != nil {
		return nil, err
	}

	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)

	if err != nil {
		return nil, err
	}

	return body, nil
}

func GetLatestModuleVersion(apiURL string) func(string) (APIResponse, error) {
	return func(name string) (APIResponse, error) {
		rawBody, apiErr := getHttpReq(apiURL, name)

		if apiErr != nil {
			errObj := APIResponse{}
			return errObj, fmt.Errorf("api error: %v", apiErr)
		}

		var body APIResponse
		jsonErr := json.Unmarshal(rawBody, &body)

		if jsonErr != nil {
			errObj := APIResponse{}
			return errObj, fmt.Errorf("json error: %v", jsonErr)
		}

		return body, nil
	}
}

func getModuleVersion(moduleSplit string) string {
	r := regexp.MustCompile(`[0-9]+\.[0-9]+\.[0-9]+|[0-9]+\.[0-9]+`)
	moduleVersion := r.FindString(moduleSplit)

	return moduleVersion
}

func isCommitSHA(ref string) bool {
	r := regexp.MustCompile(`^[0-9a-fA-F]{40}$`)
	return r.MatchString(ref)
}

func getModuleNameAndRef(fullModuleRef string) (string, bool, string) {
	delimiter := "?ref="

	containsRef := strings.Contains(fullModuleRef, delimiter)

	if !containsRef {
		delimiter = "?"
	}

	moduleSplit := strings.Split(fullModuleRef, delimiter)

	moduleName := strings.Split(moduleSplit[0], "github.com/ministryofjustice/")[1]

	if !containsRef {
		return moduleName, false, ""
	}

	return moduleName, true, moduleSplit[1]
}
