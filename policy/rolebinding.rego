package main
import future.keywords.if

deny_rolebinding[msg]  {
  input.kind == "RoleBinding"
  input.roleRef.kind == "ClusterRole"
  input.roleRef.name != "admin"
  input.roleRef.name != "calico-network-policy-access"
  msg := sprintf("ClusterRole %v is not allowed", [input.roleRef.name])
}