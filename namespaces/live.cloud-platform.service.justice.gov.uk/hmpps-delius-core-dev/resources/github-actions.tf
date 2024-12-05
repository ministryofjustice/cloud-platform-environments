module "github_actions_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  github_repositories  = ["hmpps-delius-operational-automation", "hmpps-delius-docker-images", "ndelius-um"]
  serviceaccount_rules = var.serviceaccount_rules
  # This GitHub environment will need to be created manually first
  github_environments = ["dev"]
}
