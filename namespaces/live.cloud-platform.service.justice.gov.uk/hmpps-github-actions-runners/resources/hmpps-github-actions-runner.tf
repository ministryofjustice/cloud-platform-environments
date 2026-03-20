module "hmpps_github_actions_runner" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo          = "hmpps-github-actions-runner"
  application          = "hmpps-github-actions-runner"
  github_team          = "hmpps-sre"
  environment          = var.environment
  is_production        = var.is_production
  source_template_repo = "none"
  reviewer_teams       = ["hmpps-sre"]
  github_token         = var.github_token
  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
}