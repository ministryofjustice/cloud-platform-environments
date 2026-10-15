module "hmpps_james_bootstrap" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=fef76f5b004ac10e339a170b1070b479f19018ab"
  github_repo = "hmpps-james-bootstrap"
  application = "hmpps-james-bootstrap"
  github_team = "hmpps-sre"
  environment = var.environment # 
  #reviewer_teams                = ["hmpps-dev-team-1", "hmpps-dev-team-2"] #
  selected_branch_patterns = ["main", "**/**", "**", "fix/**"] # Optional
  #protected_branches_only       = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  enable_ecr                    = true
}
