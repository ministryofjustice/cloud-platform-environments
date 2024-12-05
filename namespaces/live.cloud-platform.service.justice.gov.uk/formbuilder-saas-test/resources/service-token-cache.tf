resource "kubernetes_role" "get_configmaps_role" {
  metadata {
    name      = "formbuilder-saas-test-get-configmaps-role"
    namespace = var.namespace
  }
  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding" "get-configmaps-rolebinding" {
  metadata {
    name      = "serviceaccount_get_configmap_rolebinding"
    namespace = var.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.get_configmaps_role.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = "formbuilder-service-token-cache-cross-namespace-test-dev"
    namespace = "formbuilder-platform-test-dev"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "formbuilder-service-token-cache-cross-namespace-test-production"
    namespace = "formbuilder-platform-test-production"
  }
}