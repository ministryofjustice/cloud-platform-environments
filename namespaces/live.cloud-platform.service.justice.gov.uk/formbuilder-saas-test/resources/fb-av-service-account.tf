locals {
  fb_av_service_account_name = "formbuilder-av-test"
}

resource "kubernetes_service_account" "formbuilder_av_saas_test_service_account" {
  metadata {
    name      = local.fb_av_service_account_name
    namespace = var.namespace
  }

  secret {
    name = "${local.fb_av_service_account_name}-token"
  }

  automount_service_account_token = true
}

resource "kubernetes_secret_v1" "formbuilder_av_saas_test_service_token" {
  metadata {
    name      = "${local.fb_av_service_account_name}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.fb_av_service_account_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.formbuilder_av_saas_test_service_account
  ]
}