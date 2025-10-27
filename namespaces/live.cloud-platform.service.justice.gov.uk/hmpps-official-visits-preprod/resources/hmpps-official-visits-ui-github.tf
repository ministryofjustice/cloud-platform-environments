module "hmpps-official-visits-ui" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-official-visits-ui"
  application                   = "hmpps-official-visits-ui"
  github_team                   = "hmpps-move-and-improve"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-preprod.yaml
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "preprod" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
