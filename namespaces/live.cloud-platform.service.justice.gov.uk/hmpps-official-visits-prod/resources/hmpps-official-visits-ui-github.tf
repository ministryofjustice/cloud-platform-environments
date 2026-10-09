module "hmpps-official-visits-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-official-visits-ui"
  application                   = "hmpps-official-visits-ui"
  github_team                   = "hmpps-prison-visits-booking-live"
  environment                   = var.environment # Should match env name used in helm values e.g. values-prod.yaml
  reviewer_teams                = ["hmpps-prison-visits-booking-live", "hmpps-move-and-improve-live"]
  selected_branch_patterns      = ["main", "**/**", "**"]
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
