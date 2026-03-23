module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "serviceaccount-${var.team_name}"
  serviceaccount_token_rotated_date = "01-01-2000"

}
