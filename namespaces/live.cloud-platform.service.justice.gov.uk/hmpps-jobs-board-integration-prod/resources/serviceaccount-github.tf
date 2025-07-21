locals {
###################################################################
### Change these to the repositories managed by this namespace ###

  github_repos   = ["hmpps-jobs-board-integration-api"]

###################################################################
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
### Copy these three lines and change accordingly for your github team ###
### then add the variable name to the teams list below                 ###

data "github_team" "hmpps-sre" {
slug = "hmpps-sre"
}

data "github_team" "education-skills-work-employment" {
  slug = "education-skills-work-employment"
}

data "github_team" "education-skills-and-work-live" {
  slug = "education-skills-and-work-live"
}

##########################################################################

resource "github_repository_environment" "env" {
  for_each    = toset(local.github_repos)
  environment = var.environment
  repository  = each.key  
  prevent_self_review = true
  reviewers {
    teams = [ 
      tonumber(data.github_team.hmpps-sre.id),
      tonumber(data.github_team.education-skills-work-employment.id),
      tonumber(data.github_team.education-skills-and-work-live.id)
    ]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

# The following environment variable is used by "hmpps-github-discovery" to map the application to a namespace.
resource "github_actions_environment_variable" "namespace_env_var" {
  for_each    = toset(local.github_repos)
  repository  = each.key
  environment = var.environment
  variable_name = "KUBE_NAMESPACE"
  value = var.namespace
}
