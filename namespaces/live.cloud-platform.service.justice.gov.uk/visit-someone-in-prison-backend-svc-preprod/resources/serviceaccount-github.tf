locals {

  # Add more repos when they move from circle-ci to github actions
  github_repos   = ["hmpps-visit-allocation-api", "prisoner-contact-registry", "hmpps-notifications-alerts-vsip", "hmpps-prison-visit-booker-registry", "hmpps-manage-prison-visits-orchestration"]

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

# Service account used by github actions
module "service_account" {
  source                               = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"
  namespace                            = var.namespace
  kubernetes_cluster                   = var.kubernetes_cluster
  serviceaccount_name                  = "github-actions-sa"
  github_environments                  = [var.environment]
  github_repositories                  = local.github_repos
  github_actions_secret_kube_cert      = "KUBE_CERT"
  github_actions_secret_kube_token     = "KUBE_TOKEN"
  github_actions_secret_kube_cluster   = "KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "KUBE_NAMESPACE"
  serviceaccount_rules                 = local.github-actions-sa_rules
  serviceaccount_token_rotated_date    = time_rotating.weekly.unix
  role_name                            = "serviceaccount-github"
  rolebinding_name                     = "serviceaccount-github-rolebinding"
  depends_on                           = [github_repository_environment.env]
}

resource "time_rotating" "weekly" {
  rotation_days = 7
}

##########################################################################

data "github_team" "hmpps-prison-visits-booking" {
  slug = "hmpps-prison-visits-booking"
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
      tonumber(data.github_team.hmpps-prison-visits-booking.id)
    ]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
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