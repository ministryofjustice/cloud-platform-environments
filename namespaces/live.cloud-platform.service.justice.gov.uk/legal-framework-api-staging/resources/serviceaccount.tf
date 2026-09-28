module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_name  = "github-actions"
  serviceaccount_rules = var.serviceaccount_rules

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories                  = [var.repo_name]
  github_actions_secret_kube_cert      = "KUBE_STAGING_CERT"
  github_actions_secret_kube_token     = "KUBE_STAGING_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_STAGING_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_STAGING_NAMESPACE"
  serviceaccount_token_rotated_date = "07-09-2026"
}
