package main

valid_rolebinding := {
  "kind": "RoleBinding",
  "roleRef": {
    "kind": "ClusterRole",
    "name": "admin"
  }
}

cluster_admin_rolebinding := {
  "kind": "RoleBinding",
  "roleRef": {
    "kind": "ClusterRole",
    "name": "cluster-admin"
  }
}

msg := "ClusterRole cluster-admin is not allowed"

test_valid_rolebinding {
  not deny[msg] with input as valid_rolebinding
}

test_deny_clusteradmin {
  deny[msg] with input as cluster_admin_rolebinding
}
