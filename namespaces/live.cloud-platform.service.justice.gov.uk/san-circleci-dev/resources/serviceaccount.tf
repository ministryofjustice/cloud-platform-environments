locals {
  github_repos   = ["san-ccitypescript-test"]
  sa_rules = [
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
  serviceaccount_name                  = "san-circleci-dev"
  github_environments                  = [var.environment]
  github_repositories                  = local.github_repos
  github_actions_secret_kube_cert      = "${upper(var.environment)}_KUBE_CERT"
  github_actions_secret_kube_token     = "${upper(var.environment)}_KUBE_TOKEN"
  github_actions_secret_kube_cluster   = "${upper(var.environment)}_KUBE_CLUSTER"
  github_actions_secret_kube_namespace = "${upper(var.environment)}_KUBE_NAMESPACE"
  serviceaccount_rules                 = local.sa_rules
  serviceaccount_token_rotated_date    = time_rotating.weekly.unix
  depends_on                           = [github_repository_environment.env]
}

resource "time_rotating" "weekly" {
  rotation_days = 7
}

resource "github_repository_environment" "env" {
  for_each    = toset(concat(local.github_repos))
  environment = var.environment
  repository  = each.key
  deployment_branch_policy {
    protected_branches     = true
    custom_branch_policies = false
  }
}
