package main
import future.keywords.if

test_deny_invalid_kind_clusterrolebinding if {
  deny_clusterrolebinding["kind ClusterRoleBinding is not allowed"] with input as {
      "kind": "ClusterRoleBinding"
  }
}
