module "regression_case_feed_serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.2.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_name = "regression-case-feed"
  role_name           = "regression-case-feed-base"
  rolebinding_name    = "regression-case-feed-base"

  # The module needs one rule. The access that matters is the Role in 05-case-feed.yaml, which
  # can name a single ConfigMap.
  serviceaccount_rules = [
    {
      api_groups = [""]
      resources  = ["resourcequotas"]
      verbs      = ["get"]
    },
  ]

  serviceaccount_token_rotated_date = "02-11-2026"
}
