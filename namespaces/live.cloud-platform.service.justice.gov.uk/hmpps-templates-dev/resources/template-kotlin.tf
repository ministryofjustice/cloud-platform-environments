module "hmpps_template_kotlin" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=HEAT-463"
  github_repo                   = "hmpps-template-kotlin"
  application                   = "hmpps-template-kotlin"
  github_team                   = "hmpps-sre"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token           = var.github_token
  namespace              = var.namespace
  kubernetes_cluster     = var.kubernetes_cluster
}
