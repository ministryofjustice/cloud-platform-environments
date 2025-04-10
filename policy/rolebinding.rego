package main

deny[msg] if {
  input.kind == "RoleBinding"
  input.roleRef.kind == "ClusterRole"
  input.roleRef.name != "admin"

  msg := sprintf("ClusterRole %v is not allowed", [input.roleRef.name])
}

