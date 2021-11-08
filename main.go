package main

import (
	"fmt"

	"github.com/ministryofjustice/cloud-platform-environments/pkg/namespace"
)

func main() {
	ns, err := namespace.GetProductionNamespaces("live")

	if err != nil {
		panic(err)
	}
	fmt.Println(ns)

}
