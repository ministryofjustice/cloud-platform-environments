module "hmpps-personal-relationships-api" {
  source      = "ggithub.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"
  github_repo = "hmpps-personal-relationships-api"
  application = "hmpps-personal-relationships-api"
  github_team = "hmpps-prison-visits-booking"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-prison-visits-booking-live"] # Optional team that should review deployments to this environment.
  selected_branch_patterns      = ["main", "**/**", "**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster             = var.kubernetes_cluster
}
