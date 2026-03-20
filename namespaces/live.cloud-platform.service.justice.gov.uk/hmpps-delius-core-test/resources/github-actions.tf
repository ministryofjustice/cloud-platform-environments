module "github_actions_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  github_repositories  = ["hmpps-delius-docker-images", "ndelius-um", "pdf-generator", "ndelius-new-tech"]
  serviceaccount_rules = var.serviceaccount_rules
  # This GitHub environment will need to be created manually first
  github_environments = [var.environment_name]
  serviceaccount_token_rotated_date = "20-03-2026"
}
