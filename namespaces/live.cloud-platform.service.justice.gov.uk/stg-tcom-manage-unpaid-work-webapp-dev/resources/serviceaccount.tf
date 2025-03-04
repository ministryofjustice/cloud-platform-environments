/*
// commented out as this might not be necessary but we want to try to prompt the wild card cert behaviour
// available to the default domain name {namespace}.apps.live.cloud-platform.service.justice.gov.uk

module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  github_repositories = [var.application_ref]
}
*/