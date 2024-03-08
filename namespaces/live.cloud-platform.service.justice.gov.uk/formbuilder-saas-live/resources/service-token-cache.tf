resource "kubernetes_role" "get_configmaps_role" {
  metadata {
    name      = "formbuilder-saas-live-get-configmaps-role"
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
    name      = "formbuilder-service-token-cache-cross-namespace-live-dev"
    namespace = "formbuilder-platform-live-dev"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "formbuilder-service-token-cache-cross-namespace-live-production"
    namespace = "formbuilder-platform-live-production"
  }
}