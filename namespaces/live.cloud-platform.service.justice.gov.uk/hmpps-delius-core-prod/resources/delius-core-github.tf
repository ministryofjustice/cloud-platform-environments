module "community-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "community-api"
  application                   = "community-api"
  github_team                   = var.team_name
  environment                   = var.environment_name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "ndelius-new-tech" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "ndelius-new-tech"
  application                   = "ndelius-new-tech"
  github_team                   = var.team_name
  environment                   = var.environment_name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}

module "pdf-generator" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "pdf-generator"
  application                   = "pdf-generator"
  github_team                   = var.team_name
  environment                   = var.environment_name
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}