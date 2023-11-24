locals {
  circleci_sa_name = "circleci-formbuilder-saas-test"
}

resource "kubernetes_service_account" "circleci_formbuilder_saas_test_service_account" {
  metadata {
    name      = local.circleci_sa_name
    namespace = var.namespace
  }

  secret {
    name = "${local.circleci_sa_name}-token"
  }

  automount_service_account_token = true
}

resource "kubernetes_secret_v1" "circleci_formbuilder_saas_test_service_account_token" {
  metadata {
    name      = "${local.circleci_sa_name}-token"
    namespace = var.namespace
    annotations = {
      "kubernetes.io/service-account.name" = local.circleci_sa_name
    }
  }

  type = "kubernetes.io/service-account-token"

  depends_on = [
    kubernetes_service_account.circleci_formbuilder_saas_test_service_account
  ]
}