package main
import rego.v1

deny[msg] {
  input.kind == "ClusterRole"
  msg := "kind ClusterRole is not allowed"
}


