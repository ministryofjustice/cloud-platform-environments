package main

deny[msg] {
  input.kind == "ClusterRoleBinding"
  msg := "kind ClusterRoleBinding is not allowed"
}

