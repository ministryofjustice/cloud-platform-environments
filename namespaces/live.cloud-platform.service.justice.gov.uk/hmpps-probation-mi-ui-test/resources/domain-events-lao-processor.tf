module "domain_events_processor" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "digital-prison-reporting-lao-domain-events-processor"
  application                   = "digital-prison-reporting-lao-domain-events-processor"
  github_team                   = "hmpps-digital-prison-reporting"
  environment                   = var.environment
  reviewer_teams                = ["hmpps-digital-prison-reporting"] # Optional team that should review deployments to this environment.
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
