module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "01-01-2000"

  # GitHub Actions secrets (KUBE_CERT, KUBE_TOKEN) are created in these repos for CI/CD.
  github_repositories = ["justice-person-platform"]
}
