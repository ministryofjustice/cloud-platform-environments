package main

deny[msg] if {
  input.kind == "ClusterRole"
  msg := "kind ClusterRole is not allowed"
}


