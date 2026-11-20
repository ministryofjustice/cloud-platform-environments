module "offender_photo_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token = true
  custom_token_rotation_date = "2026-11-30"
  github_repo = "hmpps-offender-photo-api"
  application = "hmpps-offender-photo-api"
  github_team = "stg-pathfinders"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["stg-pathfinders"]
  selected_branch_patterns      = ["main", "*", "*/*"] # Any branch can deploy to test. "*" does not match "/", so "*/*" covers branches like ESUP/my-change
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
