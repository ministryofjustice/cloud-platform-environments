package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/ministryofjustice/cloud-platform-cli/pkg/util"
	app "github.com/ministryofjustice/cloud-platform-environments/cmd/repoEnvironment/app"
)

func main() {

	wd, _ := os.Getwd()
	clusterDir := "namespaces/live.cloud-platform.service.justice.gov.uk/"
	repoPath := filepath.Join(wd, clusterDir)

	folders, err := util.ListFolderPaths(repoPath)
	if err != nil {
		panic(err)
	}

	var nsFolders []string
	// Skip root folder from the list
	nsFolders = append(nsFolders, folders[1:]...)
	for _, folder := range nsFolders {
		fmt.Println("GetNamespaceDetails in : ", folder)
		ns, err := app.GetNamespaceDetails(folder)
		if err != nil {
			panic(err)
		}

		if ns.Namespace != "" && ns.IsProduction != "true" && ns.Namespace == "abundant-namespace-dev" {
			templatePath := filepath.Join(wd, "cmd/repoEnvironment/template/pspPrivRoleBinding.tmpl")
			namespaceYamlPath := fmt.Sprintf("%s/%s", folder, "pspPrivRoleBinding.yaml")
			err := ns.CreateRbPSPPrivilegedFile(templatePath, namespaceYamlPath)
			if err != nil {
				panic(err)
			}
		}

	}
}
