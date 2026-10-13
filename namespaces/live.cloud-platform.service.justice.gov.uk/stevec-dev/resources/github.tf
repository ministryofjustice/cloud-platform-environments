module "hmpps-stevec-sre-github-repo" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token            = true
  github_repo                   = "hmpps-stevec-sre-test-ui"
  application                   = "hmpps-stevec-sre-test-ui"
  github_team                   = "hmpps-sre"
  environment                   = var.environment # Should match env used in helm values e.g. values-preprod.yaml
  reviewer_teams                = ["hmpps-sre-nondevs"]
  selected_branch_patterns      = ["main", "**/**", "**"]
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-typescript"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
  github_owner                  = var.github_owner
}