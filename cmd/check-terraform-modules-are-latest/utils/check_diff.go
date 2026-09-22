package utils

import (
	"errors"
	"fmt"
	"log"
	"regexp"
	"strings"
)

func CheckModuleVersions(diff string, getVersionFn func(string) (APIResponse, error)) error {
	fileRegex := regexp.MustCompile(`^diff --git a/(.+) b/(.+)$`)
	moduleRegex := regexp.MustCompile(`^\+\s*source\s*=\s*"(github.com/ministryofjustice/cloud-platform-terraform-[^"]+)"`)

	var matches []string
	currentFile := ""

	for _, line := range strings.Split(diff, "\n") {
		fileMatch := fileRegex.FindStringSubmatch(line)

		if fileMatch != nil {
			currentFile = fileMatch[2]
			continue
		}

		// Only inspect Terraform files.
		if !strings.HasSuffix(currentFile, ".tf") {
			continue
		}

		moduleMatch := moduleRegex.FindStringSubmatch(line)

		if moduleMatch != nil {
			matches = append(matches, moduleMatch[1])
		}
	}

	if len(matches) == 0 {
		log.Println("Pass: no modules referenced ✅")
		return nil
	}

	var errs []error

	for _, module := range matches {
		if err := checkModule(module, getVersionFn); err != nil {
			errs = append(errs, err)
		}
	}

	if len(errs) > 0 {
		return errors.Join(errs...)
	}

	log.Println("Pass: you are using the latest 'cloud-platform-terraform-*' module release(s) ✅")
	return nil
}

func checkModule(module string, getVersionFn func(string) (APIResponse, error)) error {
	moduleName, containsRef, moduleRef := getModuleNameAndRef(module)

	response, responseErr := getVersionFn(moduleName)

	if responseErr != nil {
		return fmt.Errorf("Fail: could not look up latest version for %v -- %w ❌", moduleName, responseErr)
	}

	if !containsRef {
		if response.LatestVersion != "" {
			return fmt.Errorf(
				"Fail: you have not specified a module version for %v -- the latest version is %v ❌",
				module,
				response.LatestVersion,
			)
		}

		log.Println("Pass: there is no release for this module ✅")
		return nil
	}

	moduleRef = strings.TrimSpace(moduleRef)
	moduleRef = strings.Trim(moduleRef, "\"'")

	moduleVersion := getModuleVersion(moduleRef)

	if moduleVersion != "" {
		if response.LatestVersion != moduleVersion {
			return fmt.Errorf(
				"Fail: reference to %v module is not using the latest version -- %v is not the latest %v ❌",
				moduleName,
				moduleVersion,
				response.LatestVersion,
			)
		}

		return nil
	}

	if isCommitSHA(moduleRef) && moduleRef == response.LatestSHA {
		return nil
	}

	return fmt.Errorf(
		"Fail: reference to %v module is not using the latest version or commit SHA ❌",
		moduleName,
	)
}
