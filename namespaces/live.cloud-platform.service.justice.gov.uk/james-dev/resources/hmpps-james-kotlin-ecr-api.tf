module "hmpps_james_kotlin_ecr_api" {
  source                     = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.3.0"
  force_rotate_token         = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                = "hmpps-james-kotlin-ecr-api"
  application                = "hmpps-james-kotlin-ecr-api"
  github_team                = "hmpps-sre"
  environment                = var.environment
  #reviewer_teams                = ["hmpps-dev-team-1", "hmpps-dev-team-2"] 
  selected_branch_patterns = ["main", "**/**", "**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  enable_ecr                    = true
}
