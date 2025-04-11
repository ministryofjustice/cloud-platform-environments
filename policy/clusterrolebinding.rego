package main

deny[msg] if {
  input.kind == "ClusterRoleBinding"
  msg := "kind ClusterRoleBinding is not allowed"
}

