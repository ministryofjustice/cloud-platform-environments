package main

import (
	"bufio"
	"flag"
	"fmt"
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/ministryofjustice/cloud-platform-environments/cmd/namespace-labelling/utils"
)

func main() {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		log.Fatalf("Error getting home directory: %v", err)
	}

	var debug = flag.String("debug", "false", "Enable debug mode: [true/false]: (optional)")
	var environment = flag.String("env", "all", "Environment to process: [all, dev, test, uat, stage, preprod, prod, cloud-platform, other, custom]: (optional)")
	var repoPath = flag.String("repo-path", homeDir+"/repo/cloud-platform/cloud-platform-environments", "Path to your local cloud-platform-environments repository: (optional)")
	var customNamespaces = flag.String("ns", "", "Comma-separated list of custom namespaces to process: (needed if env is 'custom')")
	var help = flag.Bool("h", false, "Show help message")

	flag.Usage = func() {
		fmt.Fprintf(os.Stderr, "Namespace Tag Checker\n")
		fmt.Fprintf(os.Stderr, "=====================\n\n")
		fmt.Fprintf(os.Stderr, "This tool checks and adds missing default tags to Terraform files in Cloud Platform namespaces.\n\n")
		fmt.Fprintf(os.Stderr, "Usage: %s [options]\n\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "Options:\n")
		flag.PrintDefaults()
		fmt.Fprintf(os.Stderr, "\nExamples:\n")
		fmt.Fprintf(os.Stderr, "  %s -env=dev -debug=true\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s -env=prod -repo-path=/path/to/repo\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s -env=custom -ns=namespace1,namespace2\n", os.Args[0])
		fmt.Fprintf(os.Stderr, "  %s -h\n\n", os.Args[0])
	}
	flag.Parse()

	if *help {
		flag.Usage()
		os.Exit(0)
	}

	baseDir := filepath.Clean(*repoPath)
	if _, err := os.Stat(baseDir); os.IsNotExist(err) {
		log.Fatalf("The specified repository path does not exist: %s", baseDir)
	}

	tagChecker := utils.NewTagChecker(baseDir)

	namespaces, err := tagChecker.GetNamespaces()
	if err != nil {
		log.Fatalf("Error getting namespaces: %v", err)
	}

	categories := tagChecker.CategorizeNamespaces(namespaces)
	if *environment != "custom" {
		fmt.Printf("Found %d namespaces\n", len(namespaces))
		tagChecker.PrintCategories(categories)
	}

	var namespacesToProcess []string
	switch strings.ToLower(*environment) {
	case "sandbox":
		namespacesToProcess = categories.Sandbox
		fmt.Printf("\nProcessing %d sandbox namespaces\n", len(namespacesToProcess))
	case "dev", "development":
		namespacesToProcess = categories.Dev
		fmt.Printf("Processing %d dev namespaces\n", len(namespacesToProcess))
	case "test":
		namespacesToProcess = categories.Test
		fmt.Printf("\nProcessing %d test namespaces\n", len(namespacesToProcess))
	case "uat":
		namespacesToProcess = categories.UAT
		fmt.Printf("\nProcessing %d UAT namespaces\n", len(namespacesToProcess))
	case "stage", "staging":
		namespacesToProcess = categories.Stage
		fmt.Printf("\nProcessing %d stage namespaces\n", len(namespacesToProcess))
	case "preprod", "pre-prod":
		namespacesToProcess = categories.PreProd
		fmt.Printf("\nProcessing %d preprod namespaces\n", len(namespacesToProcess))
	case "prod", "production":
		namespacesToProcess = categories.Prod
		fmt.Printf("\nProcessing %d prod namespaces\n", len(namespacesToProcess))
	case "cloud-platform":
		namespacesToProcess = categories.CloudPlatform
		fmt.Printf("\nProcessing %d cloud-platform namespaces\n", len(namespacesToProcess))
	case "other":
		namespacesToProcess = categories.Other
		fmt.Printf("\nProcessing %d other namespaces\n", len(namespacesToProcess))
	case "all":
		namespacesToProcess = append(categories.Sandbox, categories.Dev...)
		namespacesToProcess = append(namespacesToProcess, categories.Test...)
		namespacesToProcess = append(namespacesToProcess, categories.UAT...)
		namespacesToProcess = append(namespacesToProcess, categories.Stage...)
		namespacesToProcess = append(namespacesToProcess, categories.PreProd...)
		namespacesToProcess = append(namespacesToProcess, categories.Prod...)
		namespacesToProcess = append(namespacesToProcess, categories.CloudPlatform...)
		namespacesToProcess = append(namespacesToProcess, categories.Other...)
		fmt.Printf("\nProcessing all %d namespaces\n", len(namespacesToProcess))
	case "custom":
		if *customNamespaces == "" {
			log.Fatalf("Please provide a comma-separated list of namespaces using the -namespaces flag.")
		}
		requestedNamespaces := strings.Split(*customNamespaces, ",")
		for _, ns := range requestedNamespaces {
			ns = strings.TrimSpace(ns)
			if ns != "" {
				// Check if namespace exists in the found namespaces
				for _, existingNs := range namespaces {
					if existingNs == ns {
						namespacesToProcess = append(namespacesToProcess, ns)
						break
					}
				}
			}
		}
		fmt.Printf("\nProcessing %d custom namespaces: %v\n", len(namespacesToProcess), namespacesToProcess)

		// Debug: Show requested vs found namespaces
		if *debug == "true" {
			fmt.Printf("Debug: Requested namespaces: %v\n", requestedNamespaces)
			fmt.Printf("Debug: Found namespaces: %v\n", namespacesToProcess)
			if len(namespacesToProcess) != len(requestedNamespaces) {
				fmt.Printf("Debug: Some requested namespaces were not found\n")
			}
		}
	default:
		log.Fatalf("Invalid environment: %s. Valid options: all, sandbox, dev, test, uat, stage, preprod, prod, cloud-platform, other, custom", *environment)
	}

	if len(namespacesToProcess) == 0 {
		fmt.Printf("No namespaces found for environment: %s\n", *environment)
		return
	}

	fmt.Printf("\nDo you want to check and add missing tags for %s environment(s)? (y/N): ", *environment)
	scanner := bufio.NewScanner(os.Stdin)
	scanner.Scan()
	response := strings.ToLower(strings.TrimSpace(scanner.Text()))

	if response != "y" && response != "yes" {
		fmt.Println("Exiting without making changes.")
		return
	}

	fmt.Printf("\nChecking tags for %s namespaces...\n", *environment)

	for i, ns := range namespacesToProcess {
		fmt.Printf("[%d/%d] Processing namespace: %s\n", i+1, len(namespacesToProcess), ns)
		if err := tagChecker.CheckAndAddTags(ns, *debug); err != nil {
			fmt.Printf("Error processing namespace %s: %v\n", ns, err)
		}
	}

	fmt.Printf("\nTag checking completed for %s environment(s). Processed %d namespaces.\n", *environment, len(namespacesToProcess))
}
