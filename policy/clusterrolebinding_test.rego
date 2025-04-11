package main

test_deny_invalid_kind_clusterrolebinding {
  deny["kind ClusterRoleBinding is not allowed"] with input as {
      "kind": "ClusterRoleBinding"
  }
}
