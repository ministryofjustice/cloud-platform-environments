package main

test_deny_invalid_kind_clusterrolebinding if {
  deny["kind ClusterRoleBinding is not allowed"] with input as {
      "kind": "ClusterRoleBinding"
  }
}
