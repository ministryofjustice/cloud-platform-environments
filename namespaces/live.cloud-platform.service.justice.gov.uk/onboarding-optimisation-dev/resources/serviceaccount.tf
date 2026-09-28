module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["onboarding-optimisation"]
  github_environments = ["dev"]

  serviceaccount_token_rotated_date = "16-06-2025"

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "pods/portforward",
        "pods/log",
        "deployment",
        "secrets",
        "services",
        "pods",
        "serviceaccounts",
        "configmaps",
        "persistentvolumeclaims",
      ]
      verbs = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
    {
      api_groups = ["extensions", "apps", "batch", "networking.k8s.io",
        "rbac.authorization.k8s.io", "policy"]
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
      verbs = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
    {
      api_groups = ["monitoring.coreos.com"]
      resources  = ["prometheusrules", "servicemonitors"]
      verbs      = ["*"]
    },
  ]
}
