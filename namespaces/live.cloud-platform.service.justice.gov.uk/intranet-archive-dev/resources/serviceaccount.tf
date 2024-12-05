
module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["intranet-archive"]

  github_environments = [var.environment]

  # The module's default rules, plus "statefulsets"
  serviceaccount_rules = [
    {
      "api_groups": [
        ""
      ],
      "resources": [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods"
      ],
      "verbs": [
        "patch",
        "get",
        "create",
        "update",
        "delete",
        "list",
        "watch"
      ]
    },
    {
      "api_groups": [
        "extensions",
        "apps",
        "batch",
        "networking.k8s.io",
        "policy"
      ],
      "resources": [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "statefulsets",
        "poddisruptionbudgets",
        "networkpolicies"
      ],
      "verbs": [
        "get",
        "update",
        "delete",
        "create",
        "patch",
        "list",
        "watch"
      ]
    },
    {
      "api_groups": [
        "monitoring.coreos.com"
      ],
      "resources": [
        "prometheusrules",
        "servicemonitors"
      ],
      "verbs": [
        "*"
      ]
    },
    {
      "api_groups": [
        "autoscaling"
      ],
      "resources": [
        "hpa",
        "horizontalpodautoscalers"
      ],
      "verbs": [
        "get",
        "update",
        "delete",
        "create",
        "patch"
      ]
    }
  ]
}
