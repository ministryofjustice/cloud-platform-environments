locals {
  github_repos = ["hmpps-service-catalogue", "hmpps-health-ping", "hmpps-developer-portal"]
}

module "service_account" {
  source                               = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.6"
  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  serviceaccount_name                  = "hmpps-portfolio-management"
  github_environments                  = [github_repository_environment.env.name]
  github_repositories                  = local.github_repos
  github_actions_secret_kube_cert      = "${var.environment}-KUBE_CERT"
  github_actions_secret_kube_token     = "${var.environment}-KUBE_TOKEN"
  github_actions_secret_kube_cluster   = "${var.environment}-KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "${var.environment}-KUBE_NAMESPACE"
  serviceaccount_token_rotated_date    = time_rotating.weekly.unix
}

resource "time_rotating" "weekly" {
  rotation_days = 7
}

resource "github_repository_environment" "env" {
  for_each    = toset(local.github_repos)
  environment = var.environment
  repository  = each.key
  reviewers {
    teams = [data.github_team.dps_tech.id]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

data "github_team" "dps_tech" {
  slug = "dps-tech"
}