package main
import future.keywords.if

deny_rolebinding[msg]  {
  input.kind == "RoleBinding"
  input.roleRef.kind == "ClusterRole"
  input.roleRef.name != "admin"
  msg := sprintf("ClusterRole %v is not allowed", [input.roleRef.name])
}