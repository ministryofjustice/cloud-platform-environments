module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  github_repositories = ["hmpps-james-bootstrap"]
  github_environments = ["dev"]

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "secrets",   # Helm stores release state as Secrets
        "services",  # headless Service
        "pods",      # --wait flag watches pod readiness
      ]
      verbs = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
    {
      api_groups = ["apps"]
      resources  = ["statefulsets"]
      verbs      = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
  ]
}