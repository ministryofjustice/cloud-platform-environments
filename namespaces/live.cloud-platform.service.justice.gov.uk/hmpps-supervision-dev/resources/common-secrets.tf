data "kubernetes_secret" "common" {
  metadata {
    name      = "common"
    namespace = "hmpps-probation-integration-services-${var.environment_name}"
  }
}

resource "kubernetes_secret" "common" {
  metadata {
    name      = "common"
    namespace = var.namespace
  }
  data = data.kubernetes_secret.common.data
}