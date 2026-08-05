locals {
  github_repo = "CFO-CaseAssessmentTrackingSystem"
}

data "github_team" "reviewers" {
  slug = var.team_name
}

resource "github_repository_environment" "env" {
  environment = var.github_environment_name
  repository  = local.github_repo

  # Require review from the responsible team before deploys to this environment can proceed.
  reviewers {
    teams = [data.github_team.reviewers.id]
  }
}

module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  # Environment secrets require the GitHub environment to exist first.
  depends_on = [github_repository_environment.env]

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = [local.github_repo]
  github_environments = [var.github_environment_name]

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "pods",
        "serviceaccounts",
        "configmaps",
        "persistentvolumeclaims",
      ]
      verbs = [
        "update",
        "patch",
        "get",
        "create",
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
        "rbac.authorization.k8s.io",
        "policy",
      ]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "statefulsets",
        "networkpolicies",
        "roles",
        "rolebindings",
        "poddisruptionbudgets",
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
        "servicemonitors",
      ]
      verbs = [
        "*",
      ]
    },
    {
      api_groups = [
        "autoscaling",
      ]
      resources = [
        "hpa",
        "horizontalpodautoscalers",
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
  ]

  serviceaccount_token_rotated_date = "20-03-2026"
}
