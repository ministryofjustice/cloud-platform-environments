module "hmpps_template_kotlin" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=0.0.6"
  github_repo                   = "hmpps-personal-relationships-api"
  application                   = "hmpps-personal-relationships-api"
  github_team                   = "hmpps-move-and-improve"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  reviewer_teams                = ["hmpps-sre"]
  selected_branch_patterns      = ["main"]
  application_insights_instance = "prod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
