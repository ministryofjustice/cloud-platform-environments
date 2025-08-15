module "hmpps_person_record" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-person-record"
  application = "hmpps-person-record"
  github_team = var.team_name
  environment = var.environment
  reviewer_teams                = [var.team_name]
  is_production                 = var.is_production
  application_insights_instance = var.environment
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
