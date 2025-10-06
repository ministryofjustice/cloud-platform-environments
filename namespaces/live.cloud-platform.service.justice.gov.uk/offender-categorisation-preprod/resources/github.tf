module "offender-categorisation" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "offender-categorisation"
  application                   = "offender-categorisation"
  github_team                   = "secure-estate-digital-team"
  environment                   = var.environment_name
  reviewer_teams                = ["secure-estate-digital-restricted-team"]
  is_production                 = var.is_production
  protected_branches_only       = true
  application_insights_instance = var.environment_name
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}