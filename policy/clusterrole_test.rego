package main

test_deny_invalid_kind_clusterrole {
  deny["kind ClusterRole is not allowed"] with input as {
      "kind": "ClusterRole"
  }
}

