module "migration_link_exchange_ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "migration-link-exchange-ui"
  application                   = "migration-link-exchange-ui"
  github_team                   = "data-migration-exchange"
  environment                   = var.environment
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["*"]
  kubernetes_cluster            = var.kubernetes_cluster
}
