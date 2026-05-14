module "manage-soc-cases" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "manage-soc-cases"
  application                   = "manage-soc-cases"
  github_team                   = "hmpps-security-intelligence"
  reviewer_teams                = ["hmpps-security-intelligence"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.environment_name
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "manage-soc-cases-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "manage-soc-cases-api"
  application                   = "manage-soc-cases-api"
  github_team                   = "hmpps-security-intelligence"
  reviewer_teams                = ["hmpps-security-intelligence"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.environment_name
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
