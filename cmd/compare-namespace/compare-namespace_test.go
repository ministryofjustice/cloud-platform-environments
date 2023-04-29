package main

import (
	"testing"
)

func Test_decodeFile(t *testing.T) {
	// set Mismatch File to test file
	mm.File = "templates/resources/test.tf"
	// decode test file
	blocks, err := decodeFile()
	if err != nil {
		t.Fatal(err)
	}
	// check number of blocks returned
	if len(blocks) != 3 {
		t.Fatal("File not decoded")
	}

	// check module return value
	if blocks[0].Type() != "module" {
		t.Fatal("File not decoded")
	}

	// check resource return value
	if blocks[1].Type() != "resource" {
		t.Fatal("File not decoded")
	}
}

// test reourceType function to return the resource name and namespace value from a block of code in a tf file
func Test_resourceType(t *testing.T) {
	// set Mismatch File to test file
	mm.File = "templates/resources/test.tf"

	// decode test file
	blocks, err := decodeFile()
	if err != nil {
		t.Fatal(err)
	}
	// for each block check if the name matches the expected value and print the result
	for _, b := range blocks {
		namespace, name := resourceType(b)
		if namespace != "" {
			t.Logf("Name: %s, Namespace: %s", name, namespace)
		}
	}
}

// test moduleType function to return the module name and namespace value from a block of code in a tf file
func Test_moduleType(t *testing.T) {
	// set Mismatch File to test file
	mm.File = "templates/resources/test.tf"

	// decode test file
	blocks, err := decodeFile()
	if err != nil {
		t.Fatal(err)
	}
	// for each block check if the name matches the expected value and print the result
	for _, b := range blocks {
		namespace := moduleType(b)
		if namespace != "" {
			t.Logf("Namespace: %s", namespace)
		}
	}
}
