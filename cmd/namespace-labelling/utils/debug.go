package utils

import (
	"fmt"
)

// Add a debug function to help troubleshoot directory structure
func (tc *TagChecker) DebugAddMissingTags(missingTags []string, filePath string) error {
	fmt.Printf("Debug mode enabled. The following tags would be added to %s:\n", filePath)

	if len(missingTags) == 0 {
		fmt.Printf("  No missing tags found.\n")
		return nil
	}

	fmt.Printf("\nCode blocks that would be updated:\n")
	fmt.Printf("==================================\n")

	// Show the providers block that would be added/updated
	fmt.Printf("providers \"aws\" {\n")
	fmt.Printf("  default_tags = {\n")

	for _, tag := range missingTags {
		tagValue := tc.GetTagValue(tag)
		fmt.Printf("    %-20s = %s\n", tag, tagValue)
	}

	fmt.Printf("    # ... existing tags would remain ...\n")
	fmt.Printf("  }\n")
	fmt.Printf("}\n\n")

	// Show individual tag details
	fmt.Printf("Individual tags to be added:\n")
	fmt.Printf("============================\n")
	for _, tag := range missingTags {
		tagValue := tc.GetTagValue(tag)
		fmt.Printf("  %s = %s\n", tag, tagValue)
	}

	return nil
}
