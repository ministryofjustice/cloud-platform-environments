module "serviceaccount" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"
  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  github_repositories = ["cloud-platform-how-out-of-date-are-we"]
}
