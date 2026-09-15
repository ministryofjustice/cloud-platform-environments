module "hmpps-book-a-secure-move-frontend" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-book-secure-move-api"
  application                   = "hmpps-book-secure-move-api"
  github_team                   = var.github_review_team
  environment                   = var.environment-name
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = "dev"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}