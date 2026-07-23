module "serviceaccount" {
  source             = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"
  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Creates github actions secrets containing the ca.crt and token used by
  # the octo-strategic-docs publish workflow to kubectl apply/deploy.
  github_repositories = [var.app_repo]

  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster

  serviceaccount_token_rotated_date = "23-07-2026"
}
