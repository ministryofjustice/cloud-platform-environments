module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_name = "circleci-terraform-module-formbuilder-platform-live-production"

  serviceaccount_token_rotated_date = "18-12-2023"
}