package main

import future.keywords.if

test_deny_invalid_kind_clusterrole if {
  deny["kind ClusterRole is not allowed"] with input as {
      "kind": "ClusterRole"
  }
}

