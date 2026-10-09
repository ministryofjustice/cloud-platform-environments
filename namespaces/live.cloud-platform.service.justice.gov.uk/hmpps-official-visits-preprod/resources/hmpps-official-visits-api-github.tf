module "hmpps-official-visits-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-official-visits-api"
  application                   = "hmpps-official-visits-api"
  github_team                   = "hmpps-prison-visits-booking-live"
  environment                   = var.environment # Should match env used in helm values e.g. values-preprod.yaml
  reviewer_teams                = ["hmpps-prison-visits-booking-live","move-and-improve-live"]
  selected_branch_patterns      = ["main", "**/**", "**"]
  is_production                 = var.is_production
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = [var.team_name]
}
