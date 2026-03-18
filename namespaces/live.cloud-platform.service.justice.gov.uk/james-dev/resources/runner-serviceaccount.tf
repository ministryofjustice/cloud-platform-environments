# Weekly token rotation — replaces the time_rotating in the template
resource "time_rotating" "weekly" {
  rotation_days = 7
}

module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = time_rotating.weekly.unix

  github_repositories = ["hmpps-james-bootstrap"]
  github_environments = ["dev"]

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources  = ["secrets", "services", "pods"]
      verbs      = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
    {
      api_groups = ["apps"]
      resources  = ["statefulsets"]
      verbs      = ["get", "create", "update", "patch", "delete", "list", "watch"]
    },
  ]
}