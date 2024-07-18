module "github_actions_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
}

data "kubernetes_secret_v1" "service_account_secret" {
  metadata {
    name      = module.github_actions_service_account.default_secret_name
    namespace = var.namespace
  }

  depends_on = [module.github_actions_service_account]
}

resource "github_actions_environment_secret" "github_secrets_umt" {
  for_each = {
    (var.github_actions_secret_kube_cluster)   = var.kubernetes_cluster
    (var.github_actions_secret_kube_namespace) = var.namespace
    (var.github_actions_secret_kube_cert)      = sensitive(lookup(data.kubernetes_secret_v1.service_account_secret.data, "ca.crt"))
    (var.github_actions_secret_kube_token)     = sensitive(lookup(data.kubernetes_secret_v1.service_account_secret.data, "token"))
  }
  repository      = "ndelius-um"
  environment     = var.github_environment
  secret_name     = each.key
  plaintext_value = each.value
}

resource "github_actions_environment_secret" "github_secrets_delius" {
  for_each = {
    (var.github_actions_secret_kube_cluster)   = var.kubernetes_cluster
    (var.github_actions_secret_kube_namespace) = var.namespace
    (var.github_actions_secret_kube_cert)      = sensitive(lookup(data.kubernetes_secret_v1.service_account_secret.data, "ca.crt"))
    (var.github_actions_secret_kube_token)     = sensitive(lookup(data.kubernetes_secret_v1.service_account_secret.data, "token"))
  }
  repository      = "hmpps-delius-docker-images"
  environment     = var.github_environment
  secret_name     = each.key
  plaintext_value = each.value
}
