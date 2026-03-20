module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_name = var.serviceaccount_name

  github_repositories = ["laa-data-claims-event-service"]
  github_environments = ["development"]
  serviceaccount_token_rotated_date = "20-03-2026"
}
