package main

import (
	"flag"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
)

var (
	basePath   = "namespaces/live.cloud-platform.service.justice.gov.uk"
	namespace  = flag.String("namespace", os.Getenv("NAMESPACE"), "The namespace to search")
	branchName = flag.String("branch", os.Getenv("BRANCH_NAME"), "The branch name to search")
	help       = flag.Bool("h", false, "Show help message")

	localsPattern      = regexp.MustCompile(`(?s)locals\s*\{[^{]*default_tags\s*=\s*\{([^}]+)\}`)
	awsProviderPattern = regexp.MustCompile(`(?s)provider\s+"aws"[^{]*\{[^}]*default_tags\s*\{\s*tags\s*=\s*\{([^}]+)\}`)
	tagPattern         = regexp.MustCompile(`(?m)^\s*"?([a-zA-Z][a-zA-Z0-9_-]*)"?\s*=`)
)

func main() {
	flag.Usage = printUsage
	flag.Parse()

	if *help {
		flag.Usage()
		os.Exit(0)
	}

	if *namespace == "" || *branchName == "" {
		fmt.Fprintln(os.Stderr, "Error: Both NAMESPACE and BRANCH_NAME must be set.")
		flag.Usage()
		os.Exit(1)
	}

	resourcePath := filepath.Join(basePath, *namespace, "resources", "main.tf")

	fmt.Printf("Searching for default_tags in %s on branch %s...\n\n", resourcePath, *branchName)

	content, err := getFileFromBranch(*branchName, resourcePath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error: Could not read file from branch: %v\n", err)
		os.Exit(1)
	}

	tags := findDefaultTags(content)

	if len(tags) == 0 {
		fmt.Println("❌ No default_tags found in the file.")
		os.Exit(1)
	}

	fmt.Println("✅ Found default_tags:")
	fmt.Println("======================")
	for _, tag := range tags {
		fmt.Printf("  %s\n", tag)
	}
	fmt.Printf("\nTotal tags found: %d\n", len(tags))
}

// printUsage displays the help message for the command-line tool.
func printUsage() {
	fmt.Fprintf(os.Stderr, "Branch Default Tags Checker\n")
	fmt.Fprintf(os.Stderr, "===========================\n\n")
	fmt.Fprintf(os.Stderr, "This tool searches a git branch for default_tags in Terraform main.tf files.\n\n")
	fmt.Fprintf(os.Stderr, "Usage: %s [options]\n\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "Options:\n")
	flag.PrintDefaults()
	fmt.Fprintf(os.Stderr, "\nEnvironment Variables:\n")
	fmt.Fprintf(os.Stderr, "  NAMESPACE    - The namespace to search\n")
	fmt.Fprintf(os.Stderr, "  BRANCH_NAME  - The branch name to search\n")
	fmt.Fprintf(os.Stderr, "\nExamples:\n")
	fmt.Fprintf(os.Stderr, "  %s -namespace=my-namespace -branch=my-branch\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "  NAMESPACE=my-namespace BRANCH_NAME=my-branch %s\n", os.Args[0])
	fmt.Fprintf(os.Stderr, "  %s -h\n\n", os.Args[0])
}

// getFileFromBranch retrieves the content of a file from a specific git branch using git show.
func getFileFromBranch(branch, filePath string) (string, error) {
	cmd := exec.Command("git", "show", fmt.Sprintf("%s:%s", branch, filePath))
	output, err := cmd.CombinedOutput()
	if err != nil {
		return "", fmt.Errorf("git show failed: %w - %s", err, string(output))
	}
	return string(output), nil
}

// findDefaultTags searches for default_tags in locals blocks and AWS provider blocks,
// extracts all unique tag names, and returns them as a slice.
func findDefaultTags(content string) []string {
	var tags []string
	var allTagBlocks []string

	if matches := localsPattern.FindStringSubmatch(content); len(matches) > 1 {
		allTagBlocks = append(allTagBlocks, matches[1])
	}

	if matches := awsProviderPattern.FindAllStringSubmatch(content, -1); len(matches) > 0 {
		for _, match := range matches {
			if len(match) > 1 {
				allTagBlocks = append(allTagBlocks, match[1])
			}
		}
	}

	for _, block := range allTagBlocks {
		tags = append(tags, extractTags(block)...)
	}

	seen := make(map[string]bool)
	var uniqueTags []string
	for _, tag := range tags {
		if !seen[tag] {
			seen[tag] = true
			uniqueTags = append(uniqueTags, tag)
		}
	}

	return uniqueTags
}

// extractTags parses a tag block and extracts individual tag names using regex pattern matching.
func extractTags(tagBlock string) []string {
	var tags []string

	matches := tagPattern.FindAllStringSubmatch(tagBlock, -1)
	for _, match := range matches {
		if len(match) > 1 {
			tags = append(tags, match[1])
		}
	}

	return tags
}
