module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  role_name = "serviceaccount_role_gh"

  rolebinding_name = "github-action-rolebinding"
  serviceaccount_rules = var.serviceaccount_rules

  # default value
  serviceaccount_token_rotated_date = "01-01-2000"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-fee-calculator"]

  github_environments = ["staging"]

  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
}