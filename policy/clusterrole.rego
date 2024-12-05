package main

deny[msg] {
  input.kind == "ClusterRole"
  msg := "kind ClusterRole is not allowed"
}


