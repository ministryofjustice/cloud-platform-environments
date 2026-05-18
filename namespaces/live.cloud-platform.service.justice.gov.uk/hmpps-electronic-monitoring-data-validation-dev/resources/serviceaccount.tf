module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "serviceaccount-${var.team_name}"
  serviceaccount_token_rotated_date = "01-01-2000"

  github_repositories = ["electronic-monitoring-data-dashboard"]
  github_environments = ["development"]

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
      ]
      verbs = ["patch", "get", "create", "update", "delete", "list", "watch"]
    },
    {
      api_groups = ["extensions", "apps", "batch", "networking.k8s.io", "policy"]
      resources = [
        "deployments",
        "ingresses",
        "cronjobs",
        "jobs",
        "replicasets",
        "poddisruptionbudgets",
        "networkpolicies",
      ]
      verbs = ["get", "update", "delete", "create", "patch", "list", "watch"]
    },
    {
      api_groups = ["monitoring.coreos.com"]
      resources  = ["prometheusrules", "servicemonitors"]
      verbs      = ["*"]
    },
    {
      api_groups = ["autoscaling"]
      resources  = ["hpa", "horizontalpodautoscalers"]
      verbs      = ["get", "update", "delete", "create", "patch"]
    },
    {
      api_groups = ["cert-manager.io"]
      resources  = ["issuers", "certificates", "certificaterequests"]
      verbs      = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
    {
      api_groups = ["crd.projectcalico.org"]
      resources  = ["networkpolicies"]
      verbs      = ["get", "list", "describe", "create", "delete", "watch", "update"]
    },
    {
      api_groups = ["crd.projectcalico.org"]
      resources  = ["tiers"]
      verbs      = ["get"]
    },
  ]

}
