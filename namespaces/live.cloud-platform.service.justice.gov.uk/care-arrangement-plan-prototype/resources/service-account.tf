module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  github_repositories = [var.app_repo]
  github_environments = [var.environment]
}
