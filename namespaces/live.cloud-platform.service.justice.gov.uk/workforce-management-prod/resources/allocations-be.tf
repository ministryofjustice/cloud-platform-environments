module "hmpps_allocations_prod" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=v1.1.0"
  github_repo                   = "hmpps-allocations"
  application                   = "hmpps-allocations"
  github_team                   = "hmpps-manage-a-workforce-live"
  reviewer_teams                = ["hmpps-manage-a-workforce-live"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["*"]
  kubernetes_cluster            = var.kubernetes_cluster
}