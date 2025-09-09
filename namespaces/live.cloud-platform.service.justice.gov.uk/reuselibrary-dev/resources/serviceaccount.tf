module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace           = var.namespace                  # e.g. "reuselibrary-dev"
  kubernetes_cluster  = var.kubernetes_cluster         # e.g. "live"

  # Creates repo-level secrets (ca.crt / token / server)
  github_repositories = [var.namespace]

}
