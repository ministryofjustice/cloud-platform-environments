module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = ["hmpps-person-match"]
  github_environments = ["preprod"]

  serviceaccount_name = "github-actions-serviceaccount"
  role_name           = "github-actions-serviceaccount-role"
  rolebinding_name    = "github-actions-serviceaccount-rolebinding"
}
