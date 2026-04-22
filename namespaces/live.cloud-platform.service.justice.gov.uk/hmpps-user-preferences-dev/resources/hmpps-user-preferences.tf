module "hmpps-user-preferences" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-user-preferences"
  application                   = "hmpps-user-preferences"
  github_team                   = "hmpps-probation-in-court"
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
