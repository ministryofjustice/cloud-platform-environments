module "github_actions_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  github_repositories  = ["hmpps-delius-docker-images", "ndelius-um"]
  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/exec",
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods",
        "replicationcontrollers",
        "persistentvolumeclaims",
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
        "deployments/scale",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "poddisruptionbudgets",
        "networkpolicies",
        "daemonsets",
        "statefulsets",
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
  # This GitHub environment will need to be created manually first
  github_environments = [var.environment]
  serviceaccount_token_rotated_date = "20-03-2026"
}
