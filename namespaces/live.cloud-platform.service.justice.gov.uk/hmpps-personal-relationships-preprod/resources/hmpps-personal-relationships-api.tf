module "hmpps_template_kotlin" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-personal-relationships-api"
  application                   = "hmpps-personal-relationships-api"
  github_team                   = "hmpps-prison-visits-booking-live"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  reviewer_teams                = ["hmpps-prison-visits-booking-live"]
  selected_branch_patterns      = ["main"]
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
