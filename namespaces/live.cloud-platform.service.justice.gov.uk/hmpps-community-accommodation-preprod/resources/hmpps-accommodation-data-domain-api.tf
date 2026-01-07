module "hmpps-accommodation-data-domain-api" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-accommodation-data-domain-api"
  application                   = "hmpps-accommodation-data-domain-api"
  github_team                   = "hmpps-community-accommodation-devs"
  environment                   = var.environment
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  protected_branches_only       = true
  application_insights_instance = "preprod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}