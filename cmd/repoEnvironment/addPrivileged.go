package main

import (
	"fmt"
	"os"
	"path/filepath"

	app "github.com/ministryofjustice/cloud-platform-cli/cmd/repoEnvironment/app"
	"github.com/ministryofjustice/cloud-platform-cli/pkg/util"
)

func main() {

	home, _ := os.UserHomeDir()
	clusterDir := "namespaces/live.cloud-platform.service.justice.gov.uk/"
	gitRepo := "go/src/ministryofjustice/cloud-platform-environments"
	repoPath := filepath.Join(home, gitRepo, clusterDir)

	folders, err := util.ListFolderPaths(repoPath)
	if err != nil {
		panic(err)
	}

	var nsFolders []string
	nsFolders = append(nsFolders, folders[1:]...)
	for _, folder := range nsFolders {

		fmt.Println(folder)
		err := app.ChangeDir(folder)
		if err != nil {
			panic(err)
		}
		ns, err := app.GetNamespaceDetails(folder)
		if err != nil {
			panic(err)
		}

		if ns.IsProduction != "true" && ns.Namespace == "abundant-namespace-dev" {
			templatePath := filepath.Join(home, gitRepo, "cmd/repoEnvironment/template/pspPrivRoleBinding.tmpl")

			err := ns.CreateRbPSPPrivilegedFile(templatePath, "pspPrivRoleBinding.yaml")
			if err != nil {
				panic(err)
			}

		}

	}
}
