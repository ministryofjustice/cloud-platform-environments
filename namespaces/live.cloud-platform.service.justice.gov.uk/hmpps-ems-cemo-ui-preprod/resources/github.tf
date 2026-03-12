module "hmpps-ems-cemo" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo = "hmpps-electronic-monitoring-create-an-order"
  application = "hmpps-electronic-monitoring-create-an-order"
  github_team = var.team_name
  environment = "preprod" 
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

