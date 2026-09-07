module "serviceaccount_githubactions" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "github-actions"
  role_name = "github-actions-role"
  rolebinding_name = "github-actions-rolebinding"

  serviceaccount_token_rotated_date = "25-08-2026"

  github_repositories = ["cica-apply-web"]
  github_environments = ["dev"]
}
