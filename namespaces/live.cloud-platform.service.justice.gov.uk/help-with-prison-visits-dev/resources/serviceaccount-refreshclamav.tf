locals {
  refresh_clamav_sa_rules = [
    {
      api_groups = [
        "apps",
        "extensions",
      ]
      resources = [
        "deployments",
      ]
      verbs = [
        "patch",
        "get",
      ]
    },
  ]
}

module "refresh_clamav_serviceaccount" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"
  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  serviceaccount_name  = "refreshclamav"
  role_name            = "refreshclamav"
  rolebinding_name     = "refreshclamav"
  serviceaccount_rules = local.refresh_clamav_sa_rules
  serviceaccount_token_rotated_date = "20-03-2026"
}
