# Service account for GitHub Actions CD deployment
resource "kubernetes_service_account" "deploy_user" {
  metadata {
    name      = "deploy-user"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "deploy-user"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  depends_on = []
}

# Role binding for deployment user to manage applications
resource "kubernetes_role_binding" "deploy_user_binding" {
  metadata {
    name      = "deploy-user-binding"
    namespace = var.namespace
    labels = {
      "app.kubernetes.io/name"       = "deploy-user"
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.deploy_user.metadata[0].name
    namespace = var.namespace
  }
}

# Secret to store GitHub Actions workflow token
# This output should be captured and added as K8S_TOKEN_DEV secret in GitHub
output "deploy_user_service_account_name" {
  description = "Service account name for deployment"
  value       = kubernetes_service_account.deploy_user.metadata[0].name
}
