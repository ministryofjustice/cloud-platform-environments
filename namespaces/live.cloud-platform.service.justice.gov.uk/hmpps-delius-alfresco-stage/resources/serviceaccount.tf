module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  github_repositories  = ["hmpps-delius-alfresco"]
  serviceaccount_rules = var.serviceaccount_rules
  # This GitHub environmet will need to be created manually first
  github_environments = ["stage"]
}
