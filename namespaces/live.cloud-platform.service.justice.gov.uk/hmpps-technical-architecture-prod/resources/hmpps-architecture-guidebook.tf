module "hmpps_architecture_guidebook" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  github_repo                   = "hmpps-architecture-docs"
  application                   = "hmpps-architecture-guidebook"
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
