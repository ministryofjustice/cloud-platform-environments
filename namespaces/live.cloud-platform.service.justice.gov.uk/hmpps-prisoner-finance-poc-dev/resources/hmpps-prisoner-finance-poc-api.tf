module "hmpps_prisoner_finance_poc_api" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo = "hmpps-prisoner-finance-poc-api"
  application = "hmpps-prisoner-finance-poc-api"
  github_team = "hmpps-prisoner-finance"
  environment = var.environment
  reviewer_teams                = ["hmpps-prisoner-finance"] 
  selected_branch_patterns      = ["main"] 
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
