module "github_actions_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  github_repositories = ["hmpps-breach-notice-ui", "hmpps-breach-notice-api"]
  github_environments = [var.environment_name]
}
