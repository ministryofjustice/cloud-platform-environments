module "court-hearing-event" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "court-hearing-event-receiver"
  application                   = "court-hearing-event-receiver"
  github_team                   = "probation-integration-team"
  environment                   = var.environment-name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "crime-portal-gateway" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "crime-portal-gateway"
  application                   = "crime-portal-gateway"
  github_team                   = "probation-integration-team"
  environment                   = var.environment-name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "pre-sentence-service" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "pre-sentence-service"
  application                   = "pre-sentence-service"
  github_team                   = "hmpps-probation-in-court"
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "hmpps-court-case-service-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-court-case-service-api"
  application                   = "hmpps-court-case-service-api"
  github_team                   = "hmpps-probation-in-court"
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}