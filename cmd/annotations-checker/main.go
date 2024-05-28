package main

import (
	"fmt"
	"os"
	"path/filepath"
	// "golang.org/x/text/message"
)

func main() {
	dir := "test-annotations"

	err := filepath.Walk(dir, func(path string, info os.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if !info.IsDir() && filepath.Ext(path) == ".yaml" {
			valid, message := validateAnnotations(path)
			fmt.Printf("validation result for %s: %v - %s\n", path, valid, message)
		}
		return nil
	})
	if err != nil {
		fmt.Printf("Error walking the path %s: %v\n", dir, err)
	}
}
