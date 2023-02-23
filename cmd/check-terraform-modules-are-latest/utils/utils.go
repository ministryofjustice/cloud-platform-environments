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

func getModuleNameAndVersion(fullModuleRef string) (string, bool, string) {
	delimiter := "?ref="

	containsVersion := strings.Contains(fullModuleRef, "?ref=")

	if !containsVersion {
		delimiter = "?"
	}

	moduleSplit := strings.Split(fullModuleRef, delimiter)

	moduleName := strings.Split(moduleSplit[0], "github.com/ministryofjustice/")[1]

	if !containsVersion {
		return moduleName, containsVersion, ""
	}

	moduleVersion := getModuleVersion(moduleSplit[1])

	return moduleName, containsVersion, moduleVersion
}
