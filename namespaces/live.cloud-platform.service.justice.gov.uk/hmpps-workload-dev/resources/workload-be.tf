module "hmpps_workload_dev" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=v1.1.0"
  github_repo                   = "hmpps-workload"
  application                   = "hmpps-workload"
  github_team                   = "manage-a-workforce"
  reviewer_teams                = ["manage-a-workforce"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["*"]
  kubernetes_cluster            = var.kubernetes_cluster
}