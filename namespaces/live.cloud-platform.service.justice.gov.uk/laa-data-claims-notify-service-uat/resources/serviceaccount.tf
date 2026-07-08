module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_name = var.serviceaccount_name

  github_repositories = ["laa-data-claims-notify-service"]
  github_environments = ["uat"]
  serviceaccount_token_rotated_date = "12-05-2026"
}
