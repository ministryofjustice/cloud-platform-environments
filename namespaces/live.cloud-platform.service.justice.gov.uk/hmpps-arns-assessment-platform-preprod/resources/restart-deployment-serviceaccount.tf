# Used by the aap-api-rollout-restart cronjob, which restarts the API after the weekly prod-to-preprod DB refresh
module "restart_deployment_service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name               = "restart-deployment"
  serviceaccount_token_rotated_date = "05-10-2026"
  role_name                         = "restart-deployment-role"
  rolebinding_name                  = "restart-deployment-rolebinding"
  serviceaccount_rules = [
    {
      api_groups = ["apps"]
      resources  = ["deployments"]
      verbs      = ["get", "patch"]
    }
  ]
}
