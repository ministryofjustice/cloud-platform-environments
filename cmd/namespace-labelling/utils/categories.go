package utils

import "fmt"

type NamespaceCategories struct {
	Sandbox       []string
	Dev           []string
	Test          []string
	UAT           []string
	Stage         []string
	PreProd       []string
	Prod          []string
	CloudPlatform []string
	Other         []string
}

func (tc *TagChecker) CategorizeNamespaces(namespaces []string) *NamespaceCategories {
	categories := &NamespaceCategories{}

	for _, ns := range namespaces {
		switch {
		case tc.MatchesPattern(ns, []string{"-sandbox", "sandbox", "-demo", "-prototype", "-prototypes"}):
			categories.Sandbox = append(categories.Sandbox, ns)
		case tc.MatchesPattern(ns, []string{"-dev", "dev", "-development"}):
			categories.Dev = append(categories.Dev, ns)
		case tc.MatchesPattern(ns, []string{"-test", "test", "-tst"}):
			categories.Test = append(categories.Test, ns)
		case tc.MatchesPattern(ns, []string{"-uat"}):
			categories.UAT = append(categories.UAT, ns)
		case tc.MatchesPattern(ns, []string{"-stage", "-staging", "-stag", "stg"}):
			categories.Stage = append(categories.Stage, ns)
		case tc.MatchesPattern(ns, []string{"-pre-prod", "-preprod", "-preproduction"}):
			categories.PreProd = append(categories.PreProd, ns)
		case tc.MatchesPattern(ns, []string{"-prod", "-production", "prd"}):
			categories.Prod = append(categories.Prod, ns)
		case tc.MatchesPattern(ns, []string{"cloud-platform"}):
			categories.CloudPlatform = append(categories.CloudPlatform, ns)
		default:
			categories.Other = append(categories.Other, ns)
		}
	}

	return categories
}

func (tc *TagChecker) PrintCategories(categories *NamespaceCategories) {
	fmt.Printf("Sandbox Namespaces (%d):\n", len(categories.Sandbox))
	fmt.Printf("Dev Namespaces (%d):\n", len(categories.Dev))
	fmt.Printf("Test Namespaces (%d):\n", len(categories.Test))
	fmt.Printf("UAT Namespaces (%d):\n", len(categories.UAT))
	fmt.Printf("Stage Namespaces (%d):\n", len(categories.Stage))
	fmt.Printf("PreProd Namespaces (%d):\n", len(categories.PreProd))
	fmt.Printf("Prod Namespaces (%d):\n", len(categories.Prod))
	fmt.Printf("Cloud Platform Namespaces (%d):\n", len(categories.CloudPlatform))
	fmt.Printf("Other Namespaces (%d):\n", len(categories.Other))
}
