module "offender-support-management-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "offender-support-management-ui"
  application                   = "offender-support-management-ui"
  github_team                   = "scom-tech"
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}