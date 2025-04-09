module "hmpps_sharepoint_discovery" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.0.0"
  github_repo                   = "hmpps-sharepoint-discovery"
  application                   = "hmpps-sharepoint-discovery"
  github_team                   = "hmpps-sre"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-sre"]
  protected_branches_only       = true
  is_production                 = var.is_production
  application_insights_instance = "prod"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

