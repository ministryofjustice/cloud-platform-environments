module "hmpps_architecture_patterns" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "hmpps-architecture-patterns"
  application                   = "hmpps-architecture-patterns"
  github_team                   = "hmpps-technical-architects"
  environment                   = var.environment
  reviewer_teams                = ["hmpps-technical-architects"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
