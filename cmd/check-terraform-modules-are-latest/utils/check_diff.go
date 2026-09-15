package utils

import (
	"fmt"
	"log"
	"regexp"
	"strings"
)

func CheckModuleVersions(diff string, getVersionFn func(string) (APIResponse, error)) error {
	r := regexp.MustCompile(`\+.*github.com/ministryofjustice/cloud-platform-terraform-.*"`)
	matches := r.FindAllString(diff, -1)

	if matches == nil {
		log.Println("Pass: no modules referenced ✅")
		return nil
	}

	for _, module := range matches {
		moduleName, containsRef, moduleRef := getModuleNameAndRef(module)

		response, responseErr := getVersionFn(moduleName)

		if responseErr != nil {
			return responseErr
		}

		if !containsRef {
			if response.LatestVersion != "" {
				return fmt.Errorf("Fail: you have not specified a module version for %v -- the latest version is %v ❌", module, response.LatestVersion)
			}

			log.Println("Pass: there is no release for this module ✅")
			continue
		}

		moduleRef = strings.TrimSpace(moduleRef)
		moduleRef = strings.Trim(moduleRef, "\"'")

		moduleVersion := getModuleVersion(moduleRef)

		if moduleVersion != "" {
			if response.LatestVersion != moduleVersion {
				return fmt.Errorf("Fail: reference to %v module is not using the latest version -- %v is not the latest %v ❌", moduleName, moduleVersion, response.LatestVersion)
			}

			continue
		}

		if isCommitSHA(moduleRef) && moduleRef == response.LatestSHA {
			continue
		}

		return fmt.Errorf("Fail: reference to %v module is not using the latest version or commit SHA ❌", moduleName)
	}

	log.Println("Pass: you are using the latest 'cloud-platform-terraform-*' module release(s) ✅")
	return nil
}
