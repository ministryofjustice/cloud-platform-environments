package main

deny[msg] {
  input.kind == "RoleBinding"
  input.roleRef.kind == "ClusterRole"
  input.roleRef.name == "cluster-admin"

  msg := "ClusterRole cluster-admin is not allowed"
}
