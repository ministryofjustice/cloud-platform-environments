module "hmpps-auth" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-auth"
  application                   = "hmpps-auth"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main", "**/**", "**"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-manage-users-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-manage-users"
  application                   = "hmpps-manage-users"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main", "**/**", "**"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
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
  selected_branch_patterns      = ["main", "**/**", "**"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "hmpps-external-users-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-external-users-api"
  application                   = "hmpps-external-users-api"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main", "**/**", "**"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "nomis-user-roles-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "nomis-user-roles-api"
  application                   = "nomis-user-roles-api"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main", "**/**", "**"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

module "token-verification-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "token-verification-api"
  application                   = "token-verification-api"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main", "**/**", "**"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}