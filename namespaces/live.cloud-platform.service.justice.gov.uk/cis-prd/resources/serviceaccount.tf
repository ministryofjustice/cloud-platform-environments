module "serviceaccount" {
  #checkov:skip=CKV_TF_1:Cloud Platform modules use version tags not commit hashes
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = [var.github_repository]
  github_environments = [var.github_environment]

  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace

  serviceaccount_token_rotated_date = "11-06-2026"
}
