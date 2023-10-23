module "scheduled_downtime_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name  = "scheduled-downtime-serviceaccount"
  role_name            = "scheduled-downtime-serviceaccount-role"
  rolebinding_name     = "scheduled-downtime-serviceaccount-rolebinding"
  serviceaccount_rules = [
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
