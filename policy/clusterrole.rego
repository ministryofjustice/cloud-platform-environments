package main
import rego.v1

deny[msg] if {
  input.kind == "ClusterRole"
  msg := "kind ClusterRole is not allowed"
}


