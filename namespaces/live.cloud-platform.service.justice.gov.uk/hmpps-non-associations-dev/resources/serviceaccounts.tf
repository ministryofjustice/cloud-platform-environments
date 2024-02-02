module "serviceaccount_circleci" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"

  namespace = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "circleci"
  role_name           = "circleci"
  rolebinding_name    = "circleci"

  serviceaccount_token_rotated_date = "06-02-2024"

  serviceaccount_rules = [
    {
      api_groups = ["networking.k8s.io"]
      resources  = ["networkpolicies"]
      verbs      = ["*"]
    },
    {
      api_groups = ["monitoring.coreos.com"]
      resources  = ["prometheusrules", "servicemonitors"]
      verbs      = ["*"]
    },
  ]
}

resource "kubernetes_role_binding" "circleci_edit" {
  metadata {
    namespace = var.namespace
    name      = "circleci-edit"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "edit"
  }

  subject {
    kind      = "ServiceAccount"
    namespace = var.namespace
    name      = "circleci"
  }
}
