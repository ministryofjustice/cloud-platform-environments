module "hmpps_github_actions_runner" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-template?ref=0.0.5"
  github_repo                   = "hmpps_github_actions_runner"
  application                   = "hmpps_github_actions_runner"
  github_team                   = "hmpps-sre"
  environment                   = var.environment
  is_production                 = var.is_production
  source_template_repo          = "none"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}