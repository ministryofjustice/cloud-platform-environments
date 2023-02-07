package utils

import (
	"fmt"
	"log"
	"regexp"
)

func CheckModuleVersions(diff string, getVersionFn func(string) (APIResponse, error)) error {
	// diff line starts with + and contains regex that matches the "cloud-platform-terraform-*" eg. `+  source = "github.com/ministryofjustice/cloud-platform-terraform-example"`
	r := regexp.MustCompile(`\+.*github.com/ministryofjustice/cloud-platform-terraform-.*"`)
	matches := r.FindAllString(diff, -1)

	if matches == nil {
		log.Println("Pass: no modules referenced ✅")
		return nil
	}

	for _, module := range matches {
		moduleName, containsVersion, moduleVersion := getModuleNameAndVersion(module)

		response, responseErr := getVersionFn(moduleName)

		if responseErr != nil {
			return responseErr
		}

		if !containsVersion {
			// If there is no ?ref= then still lookup the module version (some modules don't have versions because they don't have releases)
			if response.LatestVersion != "" {
				return fmt.Errorf("Fail: you have not specified a module version for %v -- the latest version is %v ❌", module, response.LatestVersion)

			}
			log.Println("Pass: there is no release for this module ✅")
			continue
		}

		if response.LatestVersion != moduleVersion {
			return fmt.Errorf("Fail: reference to %v module is not using the latest version -- %v is not the latest %v ❌", moduleName, moduleVersion, response.LatestVersion)
		}
	}

	log.Println("Pass: you are using the latest 'cloud-platform-terraform-*' module release(s) ✅")
	return nil
}
