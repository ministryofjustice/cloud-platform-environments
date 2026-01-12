module "hmpps-prisoner-communication-monitoring" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-prisoner-communication-monitoring"
  application                   = "hmpps-prisoner-communication-monitoring"
  github_team                   = "secure-estate-digital-team"
  environment                   = var.environment-name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.environment-name
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "hmpps-prisoner-communication-monitoring-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-prisoner-communication-monitoring-api"
  application                   = "hmpps-prisoner-communication-monitoring-api"
  github_team                   = "secure-estate-digital-team"
  environment                   = var.environment-name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.environment-name
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}