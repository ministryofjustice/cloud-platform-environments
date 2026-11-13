module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name               = "terraform-deployer"
  serviceaccount_token_rotated_date = "13-11-2026"

  # Credentials will be stored in Modernisation Platform AWS Secrets Manager.
  github_repositories = []
}
