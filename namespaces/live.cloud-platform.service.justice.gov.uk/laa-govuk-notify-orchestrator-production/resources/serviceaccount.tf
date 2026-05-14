module "laa_govuk_notify_orchestrator_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  # Creates Kubernetes' GitHub actions secrets in the repository
  github_repositories = ["laa_govuk_notify_orchestrator"]
  github_environments = ["production"]
}