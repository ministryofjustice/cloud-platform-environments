module "argocd_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name               = "argocd"
  role_name                         = "argocd-role"
  rolebinding_name                  = "argocd-rolebinding"
  serviceaccount_token_rotated_date = "05-11-2026"

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources  = ["configmaps", "services"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = [""]
      resources  = ["endpoints", "events", "pods"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["apps"]
      resources  = ["deployments"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["apps"]
      resources  = ["replicasets"]
      verbs      = ["get", "list", "watch"]
    },
    {
      api_groups = ["batch"]
      resources  = ["jobs"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["networking.k8s.io"]
      resources  = ["ingresses"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
    {
      api_groups = ["policy"]
      resources  = ["poddisruptionbudgets"]
      verbs      = ["get", "list", "watch", "create", "update", "patch", "delete"]
    },
  ]
}
