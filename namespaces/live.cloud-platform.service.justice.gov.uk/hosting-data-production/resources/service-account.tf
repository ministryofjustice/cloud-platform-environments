module "github_actions_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"

  # service account config
  kubernetes_cluster = var.kubernetes_cluster
  namespace          = var.namespace

  # publish creds to github actions
  github_repositories = ["hosting-data"]
}
