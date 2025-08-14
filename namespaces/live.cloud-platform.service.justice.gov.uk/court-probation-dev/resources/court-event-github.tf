module "court-hearing-event" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "court-hearing-event-receiver"
  application                   = "court-hearing-event-receiver"
  github_team                   = "probation-integration-team"
  environment                   = "dev"
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "crime-portal-gateway" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "crime-portal-gateway"
  application                   = "crime-portal-gateway"
  github_team                   = "probation-integration-team"
  environment                   = "dev"
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "pre-sentence-service" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "pre-sentence-service"
  application                   = "pre-sentence-service"
  github_team                   = "hmpps-probation-in-court"
  environment                   = "dev"
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}