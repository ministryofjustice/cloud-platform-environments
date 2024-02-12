module "serviceaccount_circleci" {
  source                            = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"
  namespace                         = var.namespace
  kubernetes_cluster                = var.kubernetes_cluster
  serviceaccount_token_rotated_date = "08-02-2024"
  serviceaccount_name               = "circleci"
  role_name                         = "circleci"
  rolebinding_name                  = "circleci"
}

