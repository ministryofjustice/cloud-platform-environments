# The Service Account for the pod broadcaster container(s).
# The broadcaster service will listen for requests and forward them to multiple pods.
# This is used for clearing nginx's (sidecar container, not ingress) cache that's on multiple pods.
module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster

  serviceaccount_rules = [
    {
      api_groups = [""]
      resources = [
        "deployment",
        "pods",
      ]
      verbs = [
        "get",
        "list",
        "watch",
      ]
    },
  ]
}
