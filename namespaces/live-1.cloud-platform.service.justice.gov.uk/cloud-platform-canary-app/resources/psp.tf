resource "kubernetes_cluster_role_binding" "cloud_platform_canary" {
  metadata {
    name = "cloud-platform-canary"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "psp:privileged"
  }
  subject {
    kind      = "Group"
    name      = "system:serviceaccounts:cloud-platform-canary-app"
    api_group = "rbac.authorization.k8s.io"
  }
}
