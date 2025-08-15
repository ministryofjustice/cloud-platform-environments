module "hmpps_person_match_score" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-person-match-score"
  application                   = "hmpps-person-match-score"
  github_team                   = var.team_name
  environment                   = var.environment
  is_production                 = var.is_production
  reviewer_teams                = [var.team_name]
  application_insights_instance = var.environment
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
