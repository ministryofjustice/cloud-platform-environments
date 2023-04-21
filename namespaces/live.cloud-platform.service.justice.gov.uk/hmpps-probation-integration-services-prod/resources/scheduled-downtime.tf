module "scheduled_downtime_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.8.1"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "scheduled-downtime-serviceaccount"
  serviceaccount_rules = [{
    api_groups = ["apps"]
    resources  = ["deployments/scale"]
    verbs      = ["patch"]
  }]
}
