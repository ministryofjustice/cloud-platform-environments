module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  github_repositories = [var.app_repo]
  github_environments = [var.environment]
  serviceaccount_token_rotated_date = "30-03-2026"
}
