package main

import (
	"context"
	"encoding/csv"
	"errors"
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"time"

	"github.com/google/go-github/v49/github"
	"golang.org/x/oauth2"
)

var (
	// Required
	sourceFiles = "namespaces/live.cloud-platform.service.justice.gov.uk/"
	// Optional
	authorName    = flag.String("author-name", "", "Name of the author of the commit.")
	authorEmail   = flag.String("author-email", "", "Email of the author of the commit.")
	prDescription = flag.String("pr-text", "", "Text to put in the description of the pull request.")
)

var (
	sourceOwner   = "ministryofjustice"
	sourceRepo    = "cloud-platform-environments"
	commitBranch  string
	commitMessage = "fix(namespaces)Remove SECRET_ROTATE_BLOCK from" + commitBranch
	baseBranch    = "main"
	prTitle       string
	prRepoOwner   = sourceOwner
	prRepo        = sourceRepo
)

var (
	client *github.Client
	ctx    = context.Background()
)

// getRef returns the commit branch reference object if it exists or creates it
// from the base branch before returning it.
func getRef() (ref *github.Reference, err error) {
	if ref, _, err = client.Git.GetRef(ctx, sourceOwner, sourceRepo, "refs/heads/"+commitBranch); err == nil {
		return ref, nil
	}

	// We consider that an error means the branch has not been found and needs to
	// be created.
	if commitBranch == baseBranch {
		return nil, errors.New("the commit branch does not exist but `basebranch` is the same as `commitBranch`")
	}

	if baseBranch == "" {
		return nil, errors.New("the `baseBranch` should not be set to an empty string when the branch specified by `commitBranch` does not exists")
	}

	var baseRef *github.Reference
	if baseRef, _, err = client.Git.GetRef(ctx, sourceOwner, sourceRepo, "refs/heads/"+baseBranch); err != nil {
		return nil, err
	}
	newRef := &github.Reference{Ref: github.String("refs/heads/" + commitBranch), Object: &github.GitObject{SHA: baseRef.Object.SHA}}
	ref, _, err = client.Git.CreateRef(ctx, sourceOwner, sourceRepo, newRef)
	return ref, err
}

// getTree generates the tree to commit based on the given files and the commit
// of the ref you got in getRef.
func getTree(ref *github.Reference, commitBranch string) (tree *github.Tree, err error) {
	// Create a tree with what to commit.
	entries := []*github.TreeEntry{}

	// Load each file into the tree.
	ns := sourceFiles + commitBranch
	file := ns + "/SECRET_ROTATE_BLOCK"
	fmt.Printf("File Path: %s\n", file)
	entries = append(entries, &github.TreeEntry{Path: github.String(file), Type: github.String("blob"), Content: nil, Mode: github.String("100644")})

	tree, _, err = client.Git.CreateTree(ctx, sourceOwner, sourceRepo, *ref.Object.SHA, entries)
	return tree, err
}

// pushCommit creates the commit in the given reference using the given tree.
func pushCommit(ref *github.Reference, tree *github.Tree) (err error) {
	// Get the parent commit to attach the commit to.
	parent, _, err := client.Repositories.GetCommit(ctx, sourceOwner, sourceRepo, *ref.Object.SHA, nil)
	if err != nil {
		return err
	}
	// This is not always populated, but is needed.
	parent.Commit.SHA = parent.SHA

	// Create the commit using the tree.
	date := time.Now()
	author := &github.CommitAuthor{Date: &date, Name: authorName, Email: authorEmail}
	commit := &github.Commit{Author: author, Message: &commitMessage, Tree: tree, Parents: []*github.Commit{parent.Commit}}
	newCommit, _, err := client.Git.CreateCommit(ctx, sourceOwner, sourceRepo, commit)
	if err != nil {
		return err
	}

	// Attach the commit to the master branch.
	ref.Object.SHA = newCommit.SHA
	_, _, err = client.Git.UpdateRef(ctx, sourceOwner, sourceRepo, ref, false)
	return err
}

// createPR creates a pull request. Based on: https://godoc.org/github.com/google/go-github/github#example-PullRequestsService-Create
func createPR() (err error) {
	prTitle = "Rotate Secrets in Namespace: " + commitBranch
	if prTitle == "" {
		return errors.New("missing Pull Request Title; skipping PR creation")
	}

	if prRepoOwner != "" && prRepoOwner != sourceOwner {
		commitBranch = fmt.Sprintf("%s:%s", sourceOwner, commitBranch)
	} else {
		prRepoOwner = sourceOwner
	}

	if prRepo == "" {
		prRepo = sourceRepo
	}

	newPR := &github.NewPullRequest{
		Title:               &prTitle,
		Head:                &commitBranch,
		Base:                &baseBranch,
		Body:                prDescription,
		MaintainerCanModify: github.Bool(true),
	}
	pr, _, err := client.PullRequests.Create(ctx, prRepoOwner, prRepo, newPR)
	if err != nil {
		return err
	}

	fmt.Printf("PR created: %s\n", pr.GetHTMLURL())
	return nil
}

func main() {
	f, err := os.Open("namespace.csv")
	if err != nil {
		log.Fatal(err)
	}

	r := csv.NewReader(f)
	for {
		record, err := r.Read()

		if err == io.EOF {
			break
		}

		if err != nil {
			log.Fatal(err)
		}

		for _, value := range record {
			commitBranch = value
			flag.Parse()
			token := os.Getenv("GITHUB_AUTH_TOKEN")
			if token == "" {
				log.Fatal("Unauthorized: No token present")
			}
			if *authorName == "" || *authorEmail == "" {
				log.Fatal("You need to specify a non-empty value for the flags `-author-name` and `-author-email`")
			}
			ts := oauth2.StaticTokenSource(&oauth2.Token{AccessToken: token})
			tc := oauth2.NewClient(ctx, ts)
			client = github.NewClient(tc)

			fmt.Printf("Namespace: %s\n", commitBranch)
			ref, err := getRef()
			if err != nil {
				log.Fatalf("Unable to get/create the commit reference: %s\n", err)
			}
			if ref == nil {
				log.Fatalf("No error where returned but the reference is nil")
			}

			tree, err := getTree(ref, commitBranch)
			if err != nil {
				log.Fatalf("Unable to create the tree based on the provided files: %s\n", err)
			}

			if err := pushCommit(ref, tree); err != nil {
				log.Fatalf("Unable to create the commit: %s\n", err)
			}

			if err := createPR(); err != nil {
				log.Fatalf("Error while creating the pull request: %s", err)
			}
		}
	}
}
