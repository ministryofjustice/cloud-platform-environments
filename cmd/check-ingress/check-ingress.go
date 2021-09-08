package main

import (
	"encoding/json"
	"flag"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/namespace"
)

type IngressReport struct {
	WeightingIngress []struct {
		Namespace string
	} `json:"weighting_ingress"`
}

var (
	branch = flag.String("branch", os.Getenv("GITHUB_REF"), "GitHub branch reference.")
	host   = flag.String("host", "https://reports.cloud-platform.service.justice.gov.uk/ingress_weighting", "hostname of hoodaw.")
	org    = flag.String("org", "ministryofjustice", "GitHub user or organisation.")
	repo   = flag.String("repo", "cloud-platform-environments", "Repository to check the PR of.")
	token  = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "Personal access token for GitHub API.")
)

func main() {
	flag.Parse()

	// Get list of namespaces to check from a pull request.
	namespaces, err := namespace.ChangedInPR(branch, token, repo, org)
	if err != nil {
		log.Fatalln("Error getting files changed in PR:", err)
	}

	// Get a list of namespaces in live-1 that don't have an annotation
	data, err := checkAnnotation(host)
	if err != nil {
		log.Fatalln("Error checking hoodaw API:", err)
	}

	// If the namespace amended by a PR doesn't have an ingress annotation: fail hard.
	for _, ingress := range data.WeightingIngress {
		for _, namespace := range namespaces {
			if ingress.Namespace == namespace {
				log.Fatalln("Namespace:", namespace, "doesn't have the correct ingress annotation.")
			}
		}
	}
}

// checkAnnotation takes a http endpoint and generates an IngressReport
// data type. IngressReport contains a collection of namespaces that contain
// an ingress resource that don't have the required annoation.
func checkAnnotation(host *string) (*IngressReport, error) {
	client := &http.Client{
		Timeout: time.Second * 2,
	}

	req, err := http.NewRequest("GET", *host, nil)
	if err != nil {
		log.Fatalln(err)
	}

	req.Header.Add("User-Agent", "ingress-annotation-check")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}

	if resp.Body != nil {
		defer resp.Body.Close()
	}

	body, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	namespaces := &IngressReport{}

	err = json.Unmarshal(body, &namespaces)
	if err != nil {
		return nil, err
	}

	return namespaces, nil
}
