module "hmpps-justice-data-agent-worker" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.2"
  github_repo                   = "hmpps-justice-data-agent-worker"
  application                   = "hmpps-justice-data-agent-worker"
  github_team                   = var.team_name
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-staging.yaml
  reviewer_teams                = [var.team_name]
  selected_branch_patterns      = ["main"]
  is_production                 = var.is_production
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

