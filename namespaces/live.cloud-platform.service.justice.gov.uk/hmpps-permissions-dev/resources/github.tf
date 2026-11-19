module "github-automation" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token            = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-permissions-api"
  application                   = "hmpps-permissions-api"
  github_team                   = var.github_review_team
  environment                   = var.environment
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  # enable_ecr is required only ONCE per Github repository.
  # Recommendation: `enable_ecr = true` on your initial namespace (eg dev)
  #                 `enable_ecr = false` (or comment it out) on others
  enable_ecr                    = true
}
