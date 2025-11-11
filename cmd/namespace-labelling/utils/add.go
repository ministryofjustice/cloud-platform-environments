package utils

import (
	"fmt"
	"os"
	"regexp"
	"strings"
)

func (tc *TagChecker) AddMissingTags(filePath, content, debug string, missingTags []string) error {
	lines := strings.Split(content, "\n")
	var newLines []string

	// add debug readonly mode to print out steps without making changes
	if debug == "true" {
		return tc.DebugAddMissingTags(missingTags, filePath)
	} else {
		// Find the default_tags block or tags block
		defaultTagsFound := false
		inDefaultTagsBlock := false
		braceCount := 0
		tagsSectionFound := false

		for _, line := range lines {
			newLines = append(newLines, line)

			// Look for default_tags block
			if matched, _ := regexp.MatchString(`\s*default_tags\s*=?\s*{`, line); matched {
				defaultTagsFound = true
				inDefaultTagsBlock = true
				braceCount = 1
			} else if inDefaultTagsBlock {
				// Count braces to track nesting
				braceCount += strings.Count(line, "{")
				braceCount -= strings.Count(line, "}")

				// Look for tags = { within default_tags
				if matched, _ := regexp.MatchString(`\s*tags\s*=\s*{`, line); matched {
					tagsSectionFound = true
					// Add missing tags after the tags = { line
					for _, tag := range missingTags {
						tagValue := tc.GetTagValue(tag)
						tagLine := fmt.Sprintf("      %s = %s", tag, tagValue)
						newLines = append(newLines, tagLine)
					}
				}

				// Check if we're closing the default_tags block
				if braceCount == 0 {
					inDefaultTagsBlock = false
				}
			}
		}

		// If no default_tags block was found, create one
		if !defaultTagsFound {
			newLines = tc.AddDefaultTagsBlock(lines)
		} else if !tagsSectionFound {
			// If default_tags exists but no tags section, we might need manual intervention
			fmt.Printf("Warning: default_tags block found but no tags section in %s\n", filePath)
		}

		// Write the modified content back to the file
		newContent := strings.Join(newLines, "\n")
		err := os.WriteFile(filePath, []byte(newContent), 0644)
		if err != nil {
			return fmt.Errorf("error writing file: %w", err)
		}
	}

	return nil
}

func (tc *TagChecker) AddDefaultTagsBlock(lines []string) []string {
	var newLines []string
	providerBlockFound := false

	for _, line := range lines {
		newLines = append(newLines, line)

		// Look for provider "aws" block opening
		if matched, _ := regexp.MatchString(`provider\s+"aws"\s*{`, line); matched {
			providerBlockFound = true

			// Add the default_tags block after provider opening
			newLines = append(newLines, "  default_tags {")
			newLines = append(newLines, "    tags = {")

			// Add all tags (not just missing ones for new blocks)
			for _, tag := range tc.searchTags {
				tagValue := tc.GetTagValue(tag)
				tagLine := fmt.Sprintf("      %s = %s", tag, tagValue)
				newLines = append(newLines, tagLine)
			}

			newLines = append(newLines, "    }")
			newLines = append(newLines, "  }")
		}
	}

	if !providerBlockFound {
		fmt.Printf("Warning: No provider 'aws' block found, manual intervention may be required\n")
	}

	return newLines
}
