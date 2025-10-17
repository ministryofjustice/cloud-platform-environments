module "serviceaccount" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-person-match"
  application                   = "hmpps-person-match"
  github_team                   = var.team_name
  environment                   = "prod"
  reviewer_teams                = [var.team_name]
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
