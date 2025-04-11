package main

test_valid_rolebinding if {
  msg := "ClusterRole cluster-admin is not allowed"
  not deny[msg] with input as {
    "kind": "RoleBinding",
    "roleRef": {
      "kind": "ClusterRole",
      "name": "admin"
    }
  }
}

test_invalid_cluster_admin_rolebinding if {
  msg := "ClusterRole cluster-admin is not allowed"
  deny[msg] with input as {
    "kind": "RoleBinding",
    "roleRef": {
      "kind": "ClusterRole",
      "name": "cluster-admin"
    }
  }
}

