module "manage-intelligence-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "manage-intelligence-api"
  application                   = "manage-intelligence-api"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main", "release"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = ["hmpps-intelligence-management"]
}

module "manage-intelligence-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "manage-intelligence"
  application                   = "manage-intelligence-ui"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main", "release"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = ["hmpps-intelligence-management"]
}

module "hmpps-submit-ims-report" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-submit-ims-report"
  application                   = "hmpps-submit-ims-report"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main", "release"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = ["hmpps-intelligence-management"]
}

module "hmpps-ims-ai-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date    = "2026-03-20"
  github_repo                   = "hmpps-ims-ai-api"
  application                   = "hmpps-ims-ai-api"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main", "release"]
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
  reviewer_teams                = ["hmpps-intelligence-management"]
}
