module "scheduled_downtime_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=remove-sa-secret-ref"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name               = "scheduled-downtime-serviceaccount"
  serviceaccount_token_rotated_date = "02-04-2024"
  role_name                         = "scheduled-downtime-serviceaccount-role"
  rolebinding_name                  = "scheduled-downtime-serviceaccount-rolebinding"
  serviceaccount_rules              = [
    {
      api_groups = ["apps"]
      resources  = ["deployments"]
      verbs      = ["get"]
    },
    {
      api_groups = ["apps"]
      resources  = ["deployments/scale"]
      verbs      = ["get", "update", "patch"]
    }
  ]
}
