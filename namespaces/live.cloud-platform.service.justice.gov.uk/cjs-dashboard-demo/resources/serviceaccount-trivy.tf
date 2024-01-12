# Service account for trivy
module "trivy" {
  source              = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.0.0"
  serviceaccount_name = "trivy"
  role_name           = "trivy"
  rolebinding_name    = "trivy"
  namespace           = var.namespace
  kubernetes_cluster  = var.kubernetes_cluster
  serviceaccount_rules = [
     {
      api_groups = [
        "aquasecurity.github.io",
      ]
      resources = [
        "vulnerabilityreports",
      ]
      verbs = [
        "get",
        "list",
      ]
    },
  ]
}
