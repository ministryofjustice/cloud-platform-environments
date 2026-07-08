package main
import future.keywords.if

deny_clusterrole[msg]  {
  input.kind == "ClusterRole"
  msg := "kind ClusterRole is not allowed"
}


