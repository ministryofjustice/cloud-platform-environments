package utils

import (
	"fmt"
	"os"
	"strings"
)

type TagChecker struct {
	searchTags []string
	baseDir    string
}

func NewTagChecker(baseDir string) *TagChecker {
	return &TagChecker{
		searchTags: []string{"business-unit", "application", "is-production", "owner", "namespace"},
		baseDir:    baseDir,
	}
}

func (tc *TagChecker) MatchesPattern(namespace string, patterns []string) bool {
	for _, pattern := range patterns {
		if strings.Contains(namespace, pattern) {
			return true
		}
	}
	return false
}

func (tc *TagChecker) CheckAndAddTags(namespace, debug string) error {
	// Find the terraform file path
	tfFilePath, err := tc.FindTerraformFile(namespace)
	if err != nil {
		fmt.Printf("Terraform file not found for namespace: %s (%v)\n", namespace, err)
		return nil // Don't treat this as a fatal error
	}

	// Check if file exists
	if _, err := os.Stat(tfFilePath); os.IsNotExist(err) {
		fmt.Printf("Terraform file not found for namespace: %s\n", namespace)
		return nil
	}

	// Read the file
	content, err := os.ReadFile(tfFilePath)
	if err != nil {
		return fmt.Errorf("error reading file %s: %w", tfFilePath, err)
	}

	// Check for missing tags
	missingTags := tc.FindMissingTags(string(content))

	if len(missingTags) > 0 {
		fmt.Printf("Namespace: %s is missing tags: %v\n", namespace, missingTags)

		// Add missing tags
		err = tc.AddMissingTags(tfFilePath, string(content), debug, missingTags)
		if err != nil {
			return fmt.Errorf("error adding tags to %s: %w", tfFilePath, err)
		}

		for _, tag := range missingTags {
			fmt.Printf("Adding tag: %s to %s\n", tag, tfFilePath)
		}
	} else {
		fmt.Printf("Namespace: %s has all default tags.\n", namespace)
	}

	return nil
}
