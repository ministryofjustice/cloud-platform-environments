package utils

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

func (tc *TagChecker) GetNamespaces() ([]string, error) {
	var namespaces []string

	// Get namespace list from cloud-platform-environments repository
	pattern := filepath.Join(tc.baseDir, "namespaces", "live.*", "*")
	matches, err := filepath.Glob(pattern)
	if err != nil {
		return nil, fmt.Errorf("error globbing directories: %w", err)
	}

	for _, match := range matches {
		info, err := os.Stat(match)
		if err != nil {
			continue
		}

		if info.IsDir() {
			namespace := filepath.Base(match)
			namespaces = append(namespaces, namespace)
		}
	}

	return namespaces, nil
}

func (tc *TagChecker) GetTagValue(tag string) string {
	switch tag {
	case "business-unit":
		return "var.business_unit"
	case "is-production":
		return "var.is_production"
	case "owner":
		return "var.team_name"
	case "application":
		return "var.application"
	case "namespace":
		return "var.namespace"
	default:
		return fmt.Sprintf("var.%s", strings.ReplaceAll(tag, "-", "_"))
	}
}
