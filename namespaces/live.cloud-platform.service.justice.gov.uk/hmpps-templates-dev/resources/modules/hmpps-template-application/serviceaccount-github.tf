locals {
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
  serviceaccount_name                  = "${var.application}-${var.serviceaccount_name}"
  github_environments                  = [var.environment]
  github_repositories                  = [var.github_repo]
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

data "github_team" "hmpps_dev_team" {
  slug = var.github_team
}

##########################################################################

resource "github_repository_environment" "env" {
  environment = var.environment
  repository  = var.github_repo
  # Not working - waiting for Cloud Platforms to help me fix this
  # prevent_self_review = true
  reviewers {
    teams = [
      tonumber(data.github_team.hmpps_dev_team.id)
    ]
  }
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}

# The following environment variable is used by "hmpps-github-discovery" to map the application to a namespace.
resource "github_actions_environment_variable" "namespace_env_var" {
  repository    = var.github_repo
  environment   = var.environment
  variable_name = "KUBE_NAMESPACE"
  value         = var.namespace
}