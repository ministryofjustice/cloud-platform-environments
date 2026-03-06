module "hmpps_component_dependencies" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo                   = "hmpps-component-dependencies"
  application                   = "hmpps-component-dependencies"
  github_team                   = "hmpps-sre"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  selected_branch_patterns      = ["main", "release/*", "feature/*", "bug/*", "**"] # Optional but required if protected_branches_only is false
  protected_branches_only       = false                                    # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev"
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}
