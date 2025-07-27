module "hmpps-education-employment-ui" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-education-employment-ui"
  application                   = "hmpps-education-employment-ui"
  github_team                   = var.team_name
  environment                   = var.deployment_environment # Should match environment name used in helm values file e.g. values-dev.yaml
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-education-employment-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-education-employment-api"
  application                   = "hmpps-education-employment-api"
  github_team                   = var.team_name
  environment                   = var.deployment_environment # Should match environment name used in helm values file e.g. values-dev.yaml
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
