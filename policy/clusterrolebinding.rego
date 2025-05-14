package main
import rego.v1

deny[msg] {
  input.kind == "ClusterRoleBinding"
  msg := "kind ClusterRoleBinding is not allowed"
}

