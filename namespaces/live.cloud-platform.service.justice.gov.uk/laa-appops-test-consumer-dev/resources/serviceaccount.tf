module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "10-04-2025"

  github_repositories = ["laa-appops-test-consumer"]
  github_environments = ["dev"]
}
