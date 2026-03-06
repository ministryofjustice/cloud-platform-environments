module "hmpps-auth" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-auth"
  application                   = "hmpps-auth"
  github_team                   = "haha-live"
  environment                   = var.environment-name
  selected_branch_patterns      = ["main", "HAAR-3277-remove-forked-oauth-library-INTEGRATION"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = var.environment-name
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}