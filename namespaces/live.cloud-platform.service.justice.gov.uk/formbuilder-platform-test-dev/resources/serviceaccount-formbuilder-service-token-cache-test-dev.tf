module "serviceaccount_formbuilder-service-token-cache-test-dev" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_token_rotated_date = "07-03-2024"

  serviceaccount_name = "formbuilder-service-token-cache-test-dev"
  role_name = "formbuilder-service-token-cache-test-dev"
  rolebinding_name = "formbuilder-service-token-cache-test-dev"
}
