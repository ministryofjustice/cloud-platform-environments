module "hmpps-jobs-board-ui" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-jobs-board-ui"
  application                   = "hmpps-jobs-board-ui"
  github_team                   = var.team_name
  environment                   = var.deployment_environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-sre", var.team_name]
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-jobs-board-api" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-jobs-board-api"
  application                   = "hmpps-jobs-board-api"
  github_team                   = var.team_name
  environment                   = var.deployment_environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-sre", var.team_name]
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.deployment_environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
