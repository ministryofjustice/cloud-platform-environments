package main

import (
	"fmt"

	"flag"
	"log"
	"os"

	githubaction "github.com/sethvargo/go-githubactions"

	utils "github.com/ministryofjustice/cloud-platform-environments/cmd/yaml-metadata-change-check/utils"
)

var (
	token    = flag.String("token", os.Getenv("GET_TOKEN"), "GitHub Personal Access Token")
	ref      = flag.String("ref", os.Getenv("GITHUB_REF"), "Branch Name")
	repo     = flag.String("repo", os.Getenv("GITHUB_REPOSITORY"), "Repository Name")
	owner    string
	repoName string
	pull     int
)

func main() {
	owner, repoName, pull = utils.GetOwnerRepoPull(*ref, *repo)

	flag.Parse()
	client := utils.GitHubClient(*token)

	files, _, err := utils.GetPullRequestFiles(client, owner, repoName, pull)
	if err != nil {
		panic(err)
	}

	for _, file := range files {
		// get pull request file
		if utils.SelectFile(file) != nil {
			//Get Branch content
			ref, err := utils.GetPullRequestBranch(client, owner, repoName, pull)
			if err != nil {
				log.Fatalf("Error fetching pull request branch: %v\n", err)
			}

			content, err := utils.GetFileContent(client, file, owner, repoName, ref)
			if err != nil {
				fmt.Printf("Policy file has been deleted, skipping")
				break
			}

			branchFile, err := utils.DecodeContent(content)
			if err != nil {
				log.Fatalf("Error decoding file content: %v\n", err)
			}

			//Get main content
			mainContent, err := utils.GetFileContent(client, file, owner, repoName, "main")
			if err != nil {
				fmt.Printf("New policy file created, skipping")
				break
			}

			mainFile, err := utils.DecodeContent(mainContent)
			if err != nil {
				log.Fatalf("Error decoding file content: %v\n", err)
			}

			splitMainDoc := utils.SplitYAMLDocuments([]byte(mainFile))
			splitBranchDoc := utils.SplitYAMLDocuments([]byte(branchFile))

			fmt.Printf("Number of documents in file %s: %d\n", *file.Filename, len(splitMainDoc))
			fmt.Printf("Number of documents in file %s: %d\n", *file.Filename, len(splitBranchDoc))

			mainPolicies := utils.ParseYAMLDocuments(splitMainDoc)
			branchPolicies := utils.ParseYAMLDocuments(splitBranchDoc)

			var expectedPolicyCountDiff int
			actualPolicyCountDiff := 0

			if (len(splitMainDoc) - len(branchPolicies)) < 0 {
				expectedPolicyCountDiff = len(branchPolicies) - len(splitMainDoc)
			} else {
				expectedPolicyCountDiff = len(splitMainDoc) - len(branchPolicies)
			}

			// Compare policies from the first file against the second file
			for _, mainPolicy := range mainPolicies {
				found := false
				for _, branchPolicy := range branchPolicies {
					if mainPolicy.Metadata.Name == branchPolicy.Metadata.Name && mainPolicy.Metadata.Namespace == branchPolicy.Metadata.Namespace {
						utils.CompareYAML(mainPolicy, branchPolicy)
						found = true
						break
					}
				}
				if !found {
					fmt.Printf("Kind %v policy, %v, in namespace %v from main %s not found in branch %s\n", mainPolicy.Kind, mainPolicy.Metadata.Name, mainPolicy.Metadata.Namespace, *file.Filename, ref)
					actualPolicyCountDiff += 1
				}
			}

			// Check for policies in the second file that are not in the first file
			for _, branchPolicy := range branchPolicies {
				found := false
				for _, mainPolicy := range mainPolicies {
					if branchPolicy.Metadata.Name == mainPolicy.Metadata.Name && branchPolicy.Metadata.Namespace == mainPolicy.Metadata.Namespace {
						found = true
						break
					}
				}
				if !found {
					fmt.Printf("Kind %v policy, %v, in namespace %v from branch %s not found in main version %s\n", branchPolicy.Kind, branchPolicy.Metadata.Name, branchPolicy.Metadata.Namespace, ref, *file.Filename)
					actualPolicyCountDiff += 1
				}
			}
			fmt.Printf("\n%d actual difference in policies in %s\n%d expected difference in %s\n", actualPolicyCountDiff, *file.Filename, expectedPolicyCountDiff, *file.Filename)

			if expectedPolicyCountDiff != actualPolicyCountDiff {
				policy_difference := actualPolicyCountDiff - expectedPolicyCountDiff
				result_comment := fmt.Sprintf("Changes to YAML .metadata.name or .metadata.namespace detected. You cannot change these fields in a single PR, please raise separate PRs to first delete the YAML policy, and then a new PR to create it with the new values.\nDetected %d policies that did not match in PR, check logs for more details.", policy_difference)
				fmt.Printf("\nFAIL - %s", result_comment)
				githubaction.SetOutput("changes", "true")
				githubaction.SetOutput("result", result_comment)
			} else {
				fmt.Printf("\nPASS")
				githubaction.SetOutput("changes", "false")
			}
		}
	}
}
