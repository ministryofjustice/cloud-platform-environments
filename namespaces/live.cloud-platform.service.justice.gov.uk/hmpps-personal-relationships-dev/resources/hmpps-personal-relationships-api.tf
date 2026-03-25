locals {

  github_repos   = ["hmpps-personal-relationships-api"]

  github-actions-sa_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods",
      ]
      verbs = [
        "patch",
        "get",
        "create",
        "update",
        "delete",
        "list",
        "watch",
      ]
    },
    {
      api_groups = [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "poddisruptionbudgets",
        "networkpolicies"
      ]
      verbs = [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch",
      ]
    },
    {
      api_groups = [
        "monitoring.coreos.com",
      ]
      resources = [
        "prometheusrules",
        "servicemonitors"
      ]
      verbs = [
        "*",
      ]
    },
  ]
}

module "hmpps_template_kotlin" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-hmpps-template?ref=1.2.1"
  force_rotate_token = true
  custom_token_rotation_date = "2026-03-20"
  github_repo                   = "hmpps-personal-relationships-api"
  application                   = "hmpps-personal-relationships-api"
  github_team                   = "hmpps-move-and-improve"
  environment                   = var.environment # Should match environment name used in helm values file e.g. values-dev.yaml
  is_production                 = var.is_production
  selected_branch_patterns      = ["main"]
  application_insights_instance = "dev" # Either "dev", "preprod" or "prod"
  source_template_repo          = "hmpps-template-kotlin"
  github_token                  = var.github_token
  namespace                     = var.namespace
  kubernetes_cluster            = var.kubernetes_cluster
}

resource "time_rotating" "weekly" {
  rotation_days = 7
}

##########################################################################

data "github_team" "hmpps-move-and-improve" {
  slug = "hmpps-move-and-improve"
}

##########################################################################

resource "github_repository_environment" "env" {
  for_each    = toset(local.github_repos)
  environment = var.environment
  repository  = each.key
  # Not working - waiting for Cloud Platforms to fix this
  # prevent_self_review = true
  reviewers {
    teams = [
      tonumber(data.github_team.hmpps-move-and-improve.id)
    ]
  }
  deployment_branch_policy {
    protected_branches     = false
    custom_branch_policies = true
  }
}

##########################################################################

resource "github_actions_environment_variable" "namespace_env_var" {
  for_each    = toset(local.github_repos)
  repository  = each.key
  environment = var.environment
  variable_name = "KUBE_NAMESPACE"
  value = var.namespace
}