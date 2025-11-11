package utils

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strings"
)

func (tc *TagChecker) FindTerraformFile(namespace string) (string, error) {
	// Try multiple glob patterns to find the terraform file
	patterns := []string{
		filepath.Join(tc.baseDir, "namespaces", "live.*", "*", namespace, "resources", "main.tf"),
		filepath.Join(tc.baseDir, "namespaces", "live-2.*", "*", namespace, "resources", "main.tf"),
	}

	for _, pattern := range patterns {
		matches, err := filepath.Glob(pattern)
		if err != nil {
			continue
		}

		if len(matches) > 0 {
			return matches[0], nil
		}
	}

	// If not found, try a more comprehensive search
	return tc.FindTerraformFileRecursive(namespace)
}

func (tc *TagChecker) FindTerraformFileRecursive(namespace string) (string, error) {
	var foundPath string

	namespacesDir := filepath.Join(tc.baseDir, "namespaces")

	err := filepath.Walk(namespacesDir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return nil // Continue walking despite errors
		}

		// Check if this is the main.tf file we're looking for
		if info.Name() == "main.tf" {
			// Check if this path contains our namespace and resources directory
			if strings.Contains(path, namespace) && strings.Contains(path, "resources") {
				// Verify this is actually the right namespace directory structure
				dir := filepath.Dir(path)
				if filepath.Base(dir) == "resources" {
					parentDir := filepath.Dir(dir)
					if filepath.Base(parentDir) == namespace {
						foundPath = path
						return filepath.SkipDir // Found it, stop walking this branch
					}
				}
			}
		}

		return nil
	})

	if err != nil {
		return "", err
	}

	if foundPath == "" {
		return "", fmt.Errorf("no terraform file found for namespace %s", namespace)
	}

	return foundPath, nil
}

func (tc *TagChecker) FindMissingTags(content string) []string {
	var missingTags []string

	// Extract default_tags blocks from providers
	defaultTagsPattern := `(?s)default_tags\s*\{[^}]*tags\s*=\s*\{[^}]*\}`
	defaultTagsRegex := regexp.MustCompile(defaultTagsPattern)
	defaultTagsMatches := defaultTagsRegex.FindAllString(content, -1)

	// Also check for default_tags = { ... } format in providers
	defaultTagsPatternAlt := `(?s)default_tags\s*=\s*\{[^}]*\}`
	defaultTagsRegexAlt := regexp.MustCompile(defaultTagsPatternAlt)
	defaultTagsMatchesAlt := defaultTagsRegexAlt.FindAllString(content, -1)

	// Extract default_tags from locals block (more common pattern)
	localsDefaultTagsPattern := `(?s)locals\s*\{[^}]*default_tags\s*=\s*\{[^}]*\}`
	localsDefaultTagsRegex := regexp.MustCompile(localsDefaultTagsPattern)
	localsDefaultTagsMatches := localsDefaultTagsRegex.FindAllString(content, -1)

	// Combine all matches
	allDefaultTagsBlocks := append(defaultTagsMatches, defaultTagsMatchesAlt...)
	allDefaultTagsBlocks = append(allDefaultTagsBlocks, localsDefaultTagsMatches...)

	// If no default_tags blocks found, all tags are missing
	if len(allDefaultTagsBlocks) == 0 {
		return tc.searchTags
	}

	// Combine all default_tags content
	combinedTagsContent := strings.Join(allDefaultTagsBlocks, " ")

	for _, tag := range tc.searchTags {
		// Check for the tag in various formats within the combined tags content
		patterns := []string{
			fmt.Sprintf(`\b%s\s*=`, tag), // business-unit =
			fmt.Sprintf(`"%s"\s*=`, tag), // "business-unit" =
			fmt.Sprintf(`'%s'\s*=`, tag), // 'business-unit' =
		}

		found := false
		for _, pattern := range patterns {
			if matched, _ := regexp.MatchString(pattern, combinedTagsContent); matched {
				found = true
				break
			}
		}

		if !found {
			missingTags = append(missingTags, tag)
		}
	}

	return missingTags
}
