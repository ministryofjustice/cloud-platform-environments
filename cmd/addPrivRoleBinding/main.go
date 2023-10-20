package main

import (
	"fmt"
	"os"
	"path/filepath"
	"strings"

	envRepo "ministryofjustice/cloud-platform-environments/pkg/repoenvironment"

	cpCliUtils "github.com/ministryofjustice/cloud-platform-cli/pkg/util"
)

func main() {

	home, _ := os.UserHomeDir()
	repoPath := filepath.Join(home, "go/src/ministryofjustice/cloud-platform-environments/namespaces/live.cloud-platform.service.justice.gov.uk/")

	folders, err := cpCliUtils.ListFolderPaths(repoPath)
	if err != nil {
		panic(err)
	}

	var nsFolders []string
	nsFolders = append(nsFolders, folders[1:]...)
	for _, folder := range nsFolders {

		fmt.Println("Folder:", folder)

		if _, err := os.Stat(folder); os.IsNotExist(err) {
			fmt.Printf("Namespace %s does not exist, skipping \n", folder)
			panic(err)
		}

		namespace := folder[strings.LastIndex(folder, ",")+1:]

		if err := os.Chdir(filepath.Join(namespace)); err != nil {
			panic(err)
		}

		ns := envRepo.Namespace{
			Namespace: folder,
		}

		err := ns.ReadYaml()
		if err != nil {
			panic(err)
		}

		println("Name:", ns.Namespace, "IsProd:", ns.IsProduction, "/n")

	}

}
