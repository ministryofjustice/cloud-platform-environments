module "hmpps_probation_mi_api_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"

  github_repo                   = "hmpps-digital-prison-reporting-mi"
  application                   = "hmpps-probation-mi-api"
  github_team                   = var.team_name
  environment                   = "probation-test"
  is_production                 = var.is_production
  application_insights_instance = "dev" # "dev", "preprod" or "prod"
  selected_branch_patterns = [
  "main",
  "DHS-705",
]
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

