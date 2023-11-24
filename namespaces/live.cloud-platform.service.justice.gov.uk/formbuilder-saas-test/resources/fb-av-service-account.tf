locals {
  sa_name = "formbuilder-av-saas-test"
}

resource "kubernetes_service_account" "formbuilder_av_saas_test_service_account" {
  metadata {
    name      = local.sa_name
    namespace = var.namespace
  }

  secret {
    name = "${local.sa_name}-token"
  }

  automount_service_account_token = true
}

resource "kubernetes_secret_v1" "formbuilder_av_saas_test_service_token" {
  metadata {
    name      = "formbuilder_av_saas_test_service_token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.formbuilder_av_saas_test_service_account
  ]
}