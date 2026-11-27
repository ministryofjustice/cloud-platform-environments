# Service Account and RBAC for managing Calico Network Policies
# This allows team members to get and update networkpolicies

module "networkpolicies_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "serviceaccount-${var.team_name}"
  serviceaccount_token_rotated_date = "01-01-2000"

  serviceaccount_rules = [
    {
      api_groups = ["crd.projectcalico.org"]
      resources  = ["networkpolicies"]
      verbs      = ["get", "list", "describe", "create", "delete", "watch", "update"]
    },
    {
      api_groups = ["crd.projectcalico.org"]
      resources  = ["tiers"]
      verbs      = ["get"]
    },
  ]
}
