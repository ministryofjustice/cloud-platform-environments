package main

import (
	"flag"
	"log"
	"os"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/ingress"
	"github.com/ministryofjustice/cloud-platform-environments/pkg/namespace"
)

var (
	branch   = flag.String("branch", os.Getenv("GITHUB_REF"), "GitHub branch reference.")
	endpoint = flag.String("endpoint", "ingress_weighting", "Endpoint of hoodaw.")
	org      = flag.String("org", "ministryofjustice", "GitHub user or organisation.")
	repo     = flag.String("repo", "cloud-platform-environments", "Repository to check the PR of.")
	token    = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "Personal access token for GitHub API.")
)

func main() {
	flag.Parse()

	// Get list of namespaces to check from a pull request.
	namespaces, err := namespace.ChangedInPR(*branch, *token, *repo, *org)
	if err != nil {
		log.Fatalln("Error getting files changed in PR:", err)
	}

	// Get a list of namespaces in live that don't have an annotation
	data, err := ingress.CheckAnnotation(*endpoint)
	if err != nil {
		log.Fatalln("Error checking hoodaw API:", err)
	}

	// If the namespace amended by a PR doesn't have an ingress annotation: fail hard.
	for _, ingress := range data.WeightingIngress {
		for _, namespace := range namespaces {
			if ingress.Namespace == namespace {
				log.Fatalln("Namespace:", namespace+"/"+ingress.Resource, "doesn't have the correct ingress annotation.")
			}
		}
	}
}
