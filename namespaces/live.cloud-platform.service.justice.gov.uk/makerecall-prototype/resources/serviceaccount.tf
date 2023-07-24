module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.3"

  namespace = var.namespace

  github_repositories = [var.namespace]
  kubernetes_cluster  = var.kubernetes_cluster
}
