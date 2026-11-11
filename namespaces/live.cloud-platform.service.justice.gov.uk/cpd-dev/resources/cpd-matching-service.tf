module "cpd-record-service" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"

  github_repo  = "cpd-matching-service"
  application  = "cpd-matching-service"
  github_team  = "justice_id"

  # Match the GitHub Actions environment
  environment = var.environment

  is_production            = var.is_production
  selected_branch_patterns = ["main"]
  protected_branches_only  = true

  application_insights_instance = "dev"
  source_template_repo          = "none"

  github_token       = var.github_token
  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
}