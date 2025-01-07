module "hmpps_template_typescript" {
  source                        = "./modules/hmpps-template-application"
  github_repo                   = "hmpps-template-typescript"
  application                   = "hmpps-template-typescript"
  github_team                   = "hmpps-sre"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  session_secret = true
  client_secret = false

  team_name              = var.team_name
  infrastructure_support = var.infrastructure_support
  kubernetes_cluster     = var.kubernetes_cluster
  vpc_name               = var.vpc_name
  github_token           = var.github_token
  namespace              = var.namespace
}
