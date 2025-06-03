module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # containing the ca.crt and token for use in github actions CI/CD pipelines
  github_repositories = ["laa-data-stewardship-access"]
}
