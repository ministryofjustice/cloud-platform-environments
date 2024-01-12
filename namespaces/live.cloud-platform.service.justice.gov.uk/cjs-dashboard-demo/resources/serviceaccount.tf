module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  github_actions_secret_kube_namespace = var.github_actions_secret_kube_namespace
  github_actions_secret_kube_cert      = var.github_actions_secret_kube_cert
  github_actions_secret_kube_token     = var.github_actions_secret_kube_token
  github_actions_secret_kube_cluster   = var.github_actions_secret_kube_cluster

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["cjs_scorecard_exploratory_analysis"]
}
