module "hmpps-manage-users" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-manage-users"
  application                   = "hmpps-manage-users"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-manage-users-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-manage-users-api"
  application                   = "hmpps-manage-users-api"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-manage-users" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-manage-users-temp-rewrite"
  application                   = "hmpps-manage-users-temp-rewrite"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}