
module "hmpps_template_typescript" {
  source      = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo = "hmpps-stevec-sre-test-ui"
  application = "hmpps-stevec-sre-test-ui"
  github_team = "hmpps-sre"
  environment = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  reviewer_teams                = ["hmpps-sre", "hmpps-sre-nondevs"] #Used for testing against HEAT-1615
  selected_branch_patterns      = ["main", "**/**", "**"]           # Optional
  #protected_branches_only      = true # Optional, defaults to true unless selected_branch_patterns is set
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}