module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  github_repositories = [var.github_repository_name]
  github_environments = [var.github_environment_name]

  github_actions_secret_kube_cert      = "DPD_KUBE_CERT"
  github_actions_secret_kube_cluster   = "DPD_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "DPD_KUBE_NAMESPACE"
  github_actions_secret_kube_token     = "DPD_KUBE_TOKEN"
}
