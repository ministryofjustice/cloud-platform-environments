resource "kubernetes_service_account_v1" "ppx_frontend" {
  metadata {
    name      = "ppx-frontend"
    namespace = var.namespace
  }

  automount_service_account_token = false
}
