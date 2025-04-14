module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  kubernetes_cluster = var.kubernetes_cluster
  namespace          = var.namespace

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "deployment",
        "secrets",
        "services",
        "configmaps",
        "pods",
        "persistentvolumeclaims",
        "serviceaccounts",
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
        "networkpolicies",
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
      ]
    },
  ]
}
