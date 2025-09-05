module "hmpps_e_surveillance_api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-e-surveillance-api"
  application                   = "hmpps-e-surveillance-api"
  github_team                   = "hmpps-e-surveillance-devs"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-e-surveillance-devs"]
  selected_branch_patterns      = ["main", "**/**", "**"] # Optional but required if protected_branches_only is false
  protected_branches_only       = false                   # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
