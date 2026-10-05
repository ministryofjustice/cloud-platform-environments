module "hmpps_digital_prison_reporting_mi_github" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"

  github_repo                   = "hmpps-digital-prison-reporting-mi"
  application                   = "hmpps-digital-prison-reporting-mi"
  github_team                   = var.team_name
  environment                   = "preprod"
  is_production                 = var.is_production
  application_insights_instance = "preprod" # "dev", "preprod" or "prod"
  selected_branch_patterns = [
  "main",
  "DHS-705",
]
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
