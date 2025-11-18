module "hmpps_template_kotlin" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-cosso-api"
  application = "hmpps-cosso-api"
  github_team = "unilink"
  environment = var.environment_name # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["unilink_admin"] # Optional team that should review deployments to this environment.
  is_production                 = var.is_production
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
