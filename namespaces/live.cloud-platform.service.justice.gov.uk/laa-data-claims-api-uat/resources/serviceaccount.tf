module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_name = var.serviceaccount_name
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
        "persistentvolumeclaims",
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
  serviceaccount_token_rotated_date = "11-06-2025"

  # Uncomment and provide repository names to create github actions secrets
  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = [
    "laa-data-claims-api",
    "bulk-submission-and-fee-scheme-tests-"
  ]
  github_environments = ["uat"]
}
