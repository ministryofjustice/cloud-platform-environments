# module "calculate-journey-variable-payments" {
#   source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
#   force_rotate_token            = true
#   protected_branches_only       = true
#   custom_token_rotation_date    = "2026-03-20"
#   application                   = "calculate-journey-variable-payments"
#   github_repo                   = "calculate-journey-variable-payments"
#   github_team                   = "map-developers-devs"
#   github_owner                  = var.github_owner
#   github_token                  = var.github_token
#   environment                   = var.environment
#   application_insights_instance = var.environment
#   namespace                     = var.namespace
#   kubernetes_cluster            = var.kubernetes_cluster
#   is_production                 = var.is_production
#   source_template_repo          = "hmpps-template-kotlin"
#   reviewer_teams                = [var.github_review_team]
# }
