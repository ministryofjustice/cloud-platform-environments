package main
import future.keywords.if

deny_clusterrolebinding[msg] {
  input.kind == "ClusterRoleBinding"
  msg := "kind ClusterRoleBinding is not allowed"
}

