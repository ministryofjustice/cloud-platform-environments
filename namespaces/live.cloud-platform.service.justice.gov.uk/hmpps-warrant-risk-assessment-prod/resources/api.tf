module "hmpps_template_kotlin" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-31"
  github_repo                   = "hmpps-warrant-risk-assessment-api"
  application                   = "hmpps-warrant-risk-assessment-api"
  github_team                   = "unilink"
  reviewer_teams                = ["unilink_admin"] # Optional team that should review deployments to this environment.
  environment                   = var.environment_name # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "prod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
