package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
)

func initEnvVars() (string, string, string, string) {
	repoName, repoNamePresent := os.LookupEnv("REPO_NAME")
	if repoName == "" || !repoNamePresent {
		log.Fatal("REPO_NAME is not set")
	}

	updatedVersion, versionPresent := os.LookupEnv("UPDATED_MODULE_VERSION")
	if updatedVersion == "" || !versionPresent {
		log.Fatal("UPDATED_MODULE_VERSION is not set")
	}

	apiURL, apiURLPresent := os.LookupEnv("API_URL")
	if apiURL == "" || !apiURLPresent {
		log.Fatal("API_URL is not set")
	}

	apiKey, apiKeyPresent := os.LookupEnv("API_KEY")
	if apiKey == "" || !apiKeyPresent {
		log.Fatal("API_KEY is not set")
	}

	return repoName, updatedVersion, apiURL, apiKey
}

func postHttpReq(apiURL, apiKey, name, version string) ([]byte, error) {
	requestURL := fmt.Sprintf("%supdate/%s/%s", apiURL, name, version)
	req, err := http.NewRequest(http.MethodPost, requestURL, nil)

	if err != nil {
		fmt.Printf("client: could not create request: %s\n", err)
		return nil, err
	}

	req.Header.Set("X-API-Key", apiKey)

	log.Println(req)

	client := http.Client{}

	res, err := client.Do(req)

	if err != nil {
		return nil, err
	}

	defer res.Body.Close()

	body, err := io.ReadAll(res.Body)

	if err != nil {
		return nil, err
	}

	return body, nil
}

func main() {
	repoName, updatedVersion, apiURL, apiKey := initEnvVars()

	resp, err := postHttpReq(apiURL, apiKey, repoName, updatedVersion)

	if err != nil {
		log.Fatal("❌ ", err)
	}

	log.Println("API Updated with new terraform module version ✅", string(resp))
}
