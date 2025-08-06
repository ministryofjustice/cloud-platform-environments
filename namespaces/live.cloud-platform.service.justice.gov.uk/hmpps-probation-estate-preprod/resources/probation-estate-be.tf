module "hmpps_probation_estate_preprod" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-probation-estate-api"
  application                   = "hmpps-probation-estate-api"
  github_team                   = "manage-a-workforce"
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["*"]
  kubernetes_cluster            = var.kubernetes_cluster
}