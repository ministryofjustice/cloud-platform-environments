package main

import (
	"context"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/google/go-github/github"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclwrite"
	"golang.org/x/oauth2"
)

// terraform variables
var (
	namespaceBlock  string
	secretNamespace string
	resourceName    []string
)

// github variables
var (
	ctx           context.Context
	token         = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "GihHub Personel token string")
	githubref     = flag.String("branch", os.Getenv("GITHUB_REF"), "GitHub branch reference.")
	gitRepo       = os.Getenv("GITHUB_REPOSITORY")
	repoNamespace string
)

// TODO listFiles will gather a list of tf files to be checked for namespace comparisons
func listFiles() string {
	var client *github.Client
	if *token == "" {
		client = github.NewClient(nil)
	} else {
		ctx = context.Background()
		ts := oauth2.StaticTokenSource(
			&oauth2.Token{AccessToken: *token},
		)
		tc := oauth2.NewClient(ctx, ts)

		client = github.NewClient(tc)
	}

	// repo user and repo name
	gitRepoS := strings.Split(gitRepo, "/")
	owner := gitRepoS[0]
	repo := gitRepoS[1]

	// get pr owner
	githubrefS := strings.Split(*githubref, "/")
	branch := githubrefS[2]
	bid, _ := strconv.Atoi(branch)

	var filename string

	prs, _, err := client.PullRequests.ListFiles(ctx, owner, repo, bid, nil)
	if err != nil {
		log.Fatal(err)
	}
	for _, pr := range prs {
		filename = *pr.Filename
	}
	return filename
}

// decodeFile for kube secrets and return namespaces that the secret is attached to
func decodeFile(filename string) error {

	if filepath.Ext(filename) == ".tf" {
		data, err := os.ReadFile(filename)

		if err != nil {
			return fmt.Errorf("error reading file %s", err)
		}

		f, diags := hclwrite.ParseConfig(data, filename, hcl.Pos{
			Line:   0,
			Column: 0,
		})

		if diags.HasErrors() {
			return fmt.Errorf("error getting TF resource: %s", diags)
		}

		blocks := f.Body().Blocks()
		for _, block := range blocks {
			if block.Type() == "resource" {
				for _, label := range block.Labels() {
					resourceType(block, label)
				}
			}
		}
	}
	return nil
}

// resouceType will search for namespace in all resources in a Pull Request
func resourceType(block *hclwrite.Block, label string) {
	if label == "kubernetes_secret" {
		resourceName = block.Labels()
		metadata := block.Body().Blocks()
		for _, m := range metadata {
			if m.Type() == "metadata" {
				for key, attr := range m.Body().Attributes() {
					if key == "namespace" {
						expr := attr.Expr()
						exprTokens := expr.BuildTokens(nil)
						var valueTokens hclwrite.Tokens
						valueTokens = append(valueTokens, exprTokens...)
						namespaceBlock = strings.TrimSpace(string(valueTokens.Bytes()))
					}
				}
			}

		}
	}
}

// varFileSearch will search for the namespace in the variables.tf file if the search returns a var.namespace
func varFileSearch(ns string, filename string) (string, error) {
	path := strings.SplitAfter(filename, "resources/")
	data, err := os.ReadFile(path[0] + "variables.tf")
	if err != nil {
		return "", fmt.Errorf("error reading file %s", err)
	}

	v, diags := hclwrite.ParseConfig(data, path[0]+"variables.tf", hcl.Pos{
		Line:   0,
		Column: 0,
	})

	if diags.HasErrors() {
		return "", fmt.Errorf("error getting TF resource: %s", diags)
	}

	var varNamespace string

	blocks := v.Body().Blocks()
	for _, block := range blocks {
		if block.Type() == "variable" {
			for _, label := range block.Labels() {
				if label == ns {
					for key, attr := range block.Body().Attributes() {
						if key == "default" {
							expr := attr.Expr()
							exprTokens := expr.BuildTokens(nil)
							var varTokens hclwrite.Tokens
							varTokens = append(varTokens, exprTokens...)
							varNamespace = strings.TrimSpace(string(varTokens.Bytes()))
						}
					}
				}
			}
		}
	}
	return varNamespace, nil
}

// TODO prComment will update PR with any findings
func prComment(filename string) {
	/**
	* TODO Return values to be passed to the PR
	* TODO Pass Filename
	* TODO Pass Repo Namespace
	* TODO Pass Sercet Name
	* TODO Pass Secret Namespace
	 */
	fmt.Println("Differnet namespaces")
	fmt.Printf("Repository Namespace: %s\nFile: %s\nResource Name: %s\nResource Namespace: %s\n", repoNamespace, filename, resourceName[1], secretNamespace)
}

func main() {
	filename := listFiles()
	filenameS := strings.Split(filename, "/")
	repoNamespace = filenameS[2]
	// filename = "/Users/jackstockley/repo/cloud-platform-environments/" + filename
	err := decodeFile(filename)
	if err != nil {
		log.Fatal(err)
	}
	if strings.Contains(namespaceBlock, "var.") {
		ns := strings.SplitAfter(namespaceBlock, ".")
		varNamespace, err := varFileSearch(ns[1], filename)
		if err != nil {
			log.Fatal(err)
		}
		secretNamespace = varNamespace
	} else {
		secretNamespace = namespaceBlock
	}

	if len(secretNamespace) > 0 && secretNamespace[len(secretNamespace)-1] == '"' {
		secretNamespace = secretNamespace[1 : len(secretNamespace)-1]
	}

	if repoNamespace != secretNamespace {

		prComment(filename)
	} else {
		fmt.Println("Matching namespaces")
		fmt.Printf("Repository Namespace: %s\nFile: %s\nResource Name: %s\nResource Namespace: %s\n", repoNamespace, filename, resourceName[1], secretNamespace)
	}
}
