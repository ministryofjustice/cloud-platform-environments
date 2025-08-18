module "hmpps_github_actions_runner_security" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.1.0"
  github_repo          = "hmpps-github-actions-runner-security"
  application          = "hmpps-github-actions-runner-security"
  github_team          = "hmpps-sre"
  environment          = var.environment
  is_production        = var.is_production
  source_template_repo = "none"
  reviewer_teams       = ["hmpps-sre"]
  github_token         = var.github_token
  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
}