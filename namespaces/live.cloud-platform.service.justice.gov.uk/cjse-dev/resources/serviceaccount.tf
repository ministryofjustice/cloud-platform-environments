module "serviceaccount" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=1.1.0"

  namespace            = var.namespace
  kubernetes_cluster   = var.kubernetes_cluster
  github_repositories  = [
                            "cjse-test",
                            "moj-cjse-xhibit-webportal",
                            "moj-cjse-xhibit-webportal-api",
                            "moj-cjse-xhibit-ingestion-api",
                            "moj-cjse-xhibit-subscription-api",
                            "moj-cjse-xhibit-notification-api",
                            "moj-cjse-xhibit-ingestion-processor",
                            "moj-cjse-xhibit-webportal-prototype"
                         ]
  serviceaccount_rules = var.serviceaccount_rules
  # This GitHub environmet will need to be created manually first
  github_environments = ["dev"]
}
