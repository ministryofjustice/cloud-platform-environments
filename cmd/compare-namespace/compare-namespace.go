package main

import (
	"context"
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strconv"
	"strings"

	"github.com/google/go-github/github"
	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclwrite"

	githubaction "github.com/sethvargo/go-githubactions"
	"golang.org/x/oauth2"
)

// github variables
var (
	client    *github.Client
	ctx       context.Context
	token     = flag.String("token", os.Getenv("GITHUB_OAUTH_TOKEN"), "GihHub Personel token string")
	githubref = flag.String("branch", os.Getenv("GITHUB_REF"), "GitHub branch reference.")
	gitRepo   = os.Getenv("GITHUB_REPOSITORY")
	mm        Mismatch
	r         Result
)

var (
	// repo user and repo name
	gitRepoS = strings.Split(gitRepo, "/")
	owner    = gitRepoS[0]
	repo     = gitRepoS[1]

	// get pr owner
	githubrefS = strings.Split(*githubref, "/")
	branch     = githubrefS[2]
	bid, _     = strconv.Atoi(branch)
)

type Mismatch struct {
	RepositoryNamespace,
	File string
	// Resource details
	ResourceTypeName,
	ResourceName,
	ResourceNamespace string
	// Module details
	ModuleTypeName,
	ModuleNamespace string
}

type Result struct {
	Result string
}

// listFiles() will gather a list of tf files to be checked for namespace comparisons using github ref for the pull request
func listFiles() []*github.CommitFile {
	prs, _, err := client.PullRequests.ListFiles(ctx, owner, repo, bid, nil)
	if err != nil {
		log.Fatal(err)
	}
	return prs
}

// decodeFile() will read tf files and return the file to for the comparison
func decodeFile() ([]*hclwrite.Block, error) {
	var blocks []*hclwrite.Block

	data, err := os.ReadFile(mm.File)

	if err != nil {
		return nil, fmt.Errorf("error reading file %s", err)
	}

	f, diags := hclwrite.ParseConfig(data, mm.File, hcl.Pos{
		Line:   0,
		Column: 0,
	})

	if diags.HasErrors() {
		return nil, fmt.Errorf("error getting TF resource: %s", diags)
	}
	blocks = f.Body().Blocks()

	return blocks, nil
}

// resouceType() will search for namespace in all resources raised in a Pull Request
func resourceType(block *hclwrite.Block) (string, string) {
	var resourceName string
	var namespaceVar string

	metadata := block.Body().Blocks()
	for _, m := range metadata {
		if m.Type() == "metadata" {
			for key, attr := range m.Body().Attributes() {
				if key == "name" {
					expr := attr.Expr()
					exprTokens := expr.BuildTokens(nil)
					var valueTokens hclwrite.Tokens
					valueTokens = append(valueTokens, exprTokens...)
					resourceName = strings.TrimSpace(string(valueTokens.Bytes()))
					if strings.Contains(resourceName, "var.") {
						n := strings.SplitAfter(resourceName, ".")
						varName, err := varFileSearch(n[1])
						if err != nil {
							log.Fatal(err)
						}
						resourceName = varName
					}
				}
				if key == "namespace" {
					expr := attr.Expr()
					exprTokens := expr.BuildTokens(nil)
					var valueTokens hclwrite.Tokens
					valueTokens = append(valueTokens, exprTokens...)
					namespaceVar = strings.TrimSpace(string(valueTokens.Bytes()))
					if strings.Contains(namespaceVar, "var.") {
						ns := strings.SplitAfter(namespaceVar, ".")
						varNamespace, err := varFileSearch(ns[1])
						if err != nil {
							log.Fatal(err)
						}
						namespaceVar = varNamespace
					}
				}
			}
		}
	}
	return namespaceVar, resourceName
}

// moduleType() will search for namespace in all modules raise in a Pull Request
func moduleType(block *hclwrite.Block) string {
	var namespaceVar string
	body := block.Body()
	if body.Attributes()["namespace"] != nil {
		expr := body.Attributes()["namespace"].Expr()
		exprTokens := expr.BuildTokens(nil)
		var valueTokens hclwrite.Tokens
		valueTokens = append(valueTokens, exprTokens...)
		namespaceVar = strings.TrimSpace(string(valueTokens.Bytes()))
		if strings.Contains(namespaceVar, "var.") {
			ns := strings.SplitAfter(namespaceVar, ".")
			varNamespace, err := varFileSearch(ns[1])
			if err != nil {
				log.Fatal(err)
			}
			namespaceVar = varNamespace
		}
	}
	return namespaceVar
}

// varFileSearch() will search for the namespace in the variables.tf file if the search contians 'var.'
func varFileSearch(ns string) (string, error) {
	path := strings.SplitAfter(mm.File, "resources/")
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

	var vn string

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
							vn = strings.TrimSpace(string(varTokens.Bytes()))
						}
					}
				}
			}
		}
	}
	return vn, nil
}

// prMessage() adds a meesage to a pull request if there is a mismatch,
// customising the message depending if its a resource or module
func prMessage(t string) {
	githubaction.SetOutput("mismatch", "true")
	switch {
	case t == "resource":
		r.Result = fmt.Sprintf("\nRepository Namespace: %s\nFile: %s\nResource: %s\nResource Name: %s\nResource Namespace: %s\n", mm.RepositoryNamespace, mm.File, mm.ResourceTypeName, mm.ResourceName, mm.ResourceNamespace)
		fmt.Println(r.Result)
	case t == "module":
		r.Result = fmt.Sprintf("\nRepository Namespace: %s\nFile: %s\nModule: %s\nModule Namespace: %s\n", mm.RepositoryNamespace, mm.File, mm.ModuleTypeName, mm.ModuleNamespace)
		fmt.Println(r.Result)
	}
}

func main() {
	ctx = context.Background()
	ts := oauth2.StaticTokenSource(
		&oauth2.Token{AccessToken: *token},
	)
	tc := oauth2.NewClient(ctx, ts)

	client = github.NewClient(tc)
	if *token == "" {
		client = github.NewClient(nil)
	}

	prs := listFiles()
	// setting stdout to a file
	fname := filepath.Join(os.TempDir(), "stdout")
	old := os.Stdout            // keep backup of the real stdout
	temp, _ := os.Create(fname) // create temp file
	os.Stdout = temp

	for _, pr := range prs {
		mm.File = *pr.Filename
		if filepath.Ext(mm.File) == ".tf" {
			fileS := strings.Split(mm.File, "/")
			mm.RepositoryNamespace = fileS[2]
			blocks, err := decodeFile()
			if err != nil {
				log.Fatal(err)
			}
			for _, block := range blocks {
				switch {
				case block.Type() == "resource":
					rtn := block.Labels()
					mm.ResourceTypeName = "[" + rtn[0] + "]" + " - " + rtn[1]
					mm.ResourceNamespace, mm.ResourceName = resourceType(block)
					if mm.ResourceNamespace == "" {
						fmt.Printf("No Namespace data found in Resource: %s - skipping...\n", mm.ResourceTypeName)
					} else if !strings.Contains(mm.ResourceNamespace, mm.RepositoryNamespace) {
						prMessage("resource")
					}
				case block.Type() == "module":
					mtn := block.Labels()
					mm.ModuleTypeName = mtn[0]
					mm.ModuleNamespace = moduleType(block)
					if mm.ModuleNamespace == "" {
						fmt.Println("No Namespace data found in Module: %s - skipping...\n", mm.ModuleTypeName)
					} else if !strings.Contains(mm.ModuleNamespace, mm.RepositoryNamespace) {
						prMessage("module")
					}
				}
			}
		}
	}
	// back to normal state
	temp.Close()
	os.Stdout = old // restoring the real stdout

	// reading our temp stdout
	out, _ := ioutil.ReadFile(fname)
	fmt.Print(string(out))
	githubaction.SetOutput("result", string(out))
}
