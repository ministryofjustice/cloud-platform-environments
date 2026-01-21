module "wmt_worker_dev" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=v1.1.0"
  github_repo                   = "wmt-worker"
  application                   = "wmt-worker"
  github_team                   = "hmpps-manage-a-workforce-devs"
  reviewer_teams                = ["hmpps-manage-a-workforce-devs"]
  environment                   = var.environment_name
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  selected_branch_patterns      = ["*"]
  kubernetes_cluster            = var.kubernetes_cluster
}