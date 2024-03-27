module "serviceaccount" {
  source                            = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.1"
  namespace                         = var.namespace
  kubernetes_cluster                = var.kubernetes_cluster
  serviceaccount_name               = "circleci"
  serviceaccount_token_rotated_date = "28-03-2024"
  role_name                         = "circleci"
}
