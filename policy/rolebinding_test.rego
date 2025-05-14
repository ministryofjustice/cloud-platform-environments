package main
import future.keywords.if

test_valid_rolebinding if {
  msg := "ClusterRole cluster-admin is not allowed"
  not deny_rolebinding[msg] with input as {
    "kind": "RoleBinding",
    "roleRef": {
      "kind": "ClusterRole",
      "name": "admin"
    }
  }
}

test_invalid_cluster_admin_rolebinding if {
  msg := "ClusterRole cluster-admin is not allowed"
  deny_rolebinding[msg] with input as {
    "kind": "RoleBinding",
    "roleRef": {
      "kind": "ClusterRole",
      "name": "cluster-admin"
    }
  }
}

