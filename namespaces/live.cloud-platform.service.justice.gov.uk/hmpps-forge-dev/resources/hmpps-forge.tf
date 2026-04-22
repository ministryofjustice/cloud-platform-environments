module "hmpps_forge" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  github_repo                   = "hmpps-forge"
  application                   = "hmpps-forge"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}
