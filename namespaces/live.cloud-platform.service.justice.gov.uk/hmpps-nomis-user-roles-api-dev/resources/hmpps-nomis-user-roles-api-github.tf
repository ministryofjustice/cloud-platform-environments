module "nomis-user-roles-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "nomis-user-roles-api"
  application                   = "nomis-user-roles-api"
  github_team                   = "haha-live"
  environment                   = var.environment
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}