module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  github_repositories = ["address-matcher-api"]
  github_environments = ["dev", "prod"]
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
        "servicemonitors",
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
      # The dev benchmark job runs a command in a dev pod to mint a benchmark token.
      api_groups = [""]
      resources = [
        "pods/exec",
      ]
      verbs = [
        "create",
      ]
    },
    {
      api_groups = [
        "monitoring.coreos.com",
      ]
      resources = [
        "prometheusrules",
      ]
      verbs = [
        "*",
      ]
    },
  ]
}
