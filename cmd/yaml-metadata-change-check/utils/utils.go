package utils

import (
	"bytes"
	"fmt"
	"strconv"
	"strings"

	"gopkg.in/yaml.v2"
)

func GetOwnerRepoPull(ref, repo string) (string, string, int) {
	// get pull request files
	githubrefS := strings.Split(ref, "/")
	prnum := githubrefS[2]
	pull, _ := strconv.Atoi(prnum)

	repoS := strings.Split(repo, "/")
	owner := repoS[0]
	repoName := repoS[1]

	return owner, repoName, pull
}

func SplitYAMLDocuments(data []byte) [][]byte {
	var docs [][]byte
	decoder := yaml.NewDecoder(bytes.NewReader(data))
	for {
		var doc interface{}
		err := decoder.Decode(&doc)
		if err != nil {
			break
		}
		docBytes, _ := yaml.Marshal(doc)
		docs = append(docs, docBytes)
	}
	return docs
}

func ParseYAMLDocuments(documents [][]byte) []YAML {
	var policies []YAML
	for _, doc := range documents {
		var policy YAML
		err := yaml.Unmarshal(doc, &policy)
		if err != nil {
			fmt.Println(err)
			continue
		}
		policies = append(policies, policy)
	}
	return policies
}

func CompareYAML(yaml1, yaml2 YAML) {
	fmt.Println("Start comparing YAML polciy")
	if yaml1.Kind != yaml2.Kind {
		fmt.Printf("Kind = MISMATCH: %v != %v\n", yaml1.Kind, yaml2.Kind)

	} else {
		fmt.Printf("Kind = MATCH: %v\n", yaml1.Kind)
	}

	if yaml1.Metadata.Name != yaml2.Metadata.Name {
		fmt.Printf("Metadata.Name = MISMATCH: %v != %v\n", yaml1.Metadata.Name, yaml2.Metadata.Name)
	} else {
		fmt.Printf("Metadata.Name = MATCH: %v\n", yaml1.Metadata.Name)
	}

	if yaml1.Metadata.Namespace != yaml2.Metadata.Namespace {
		fmt.Printf("Metadata.Namespace = MISMATCH: %v != %v\n", yaml1.Metadata.Namespace, yaml2.Metadata.Namespace)
	} else {
		fmt.Printf("Metadata.Namespace = MATCH: %v\n", yaml1.Metadata.Namespace)
	}
	fmt.Printf("Finished comparing polciy\n\n")
}
