module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name               = "terraform-deployer"
  serviceaccount_token_rotated_date = "13-11-2026"
}

resource "kubernetes_service_account_v1" "eso" {
  metadata {
    namespace = var.namespace
    name      = "github-sts-eso"
    annotations = {
      "eks.amazonaws.com/role-arn" = "arn:aws:iam::031879841473:role/github-sts-cloud-platform-eso"
    }
  }
}
