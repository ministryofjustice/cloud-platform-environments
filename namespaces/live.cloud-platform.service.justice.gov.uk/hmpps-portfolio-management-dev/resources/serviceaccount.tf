
module "service_account" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-serviceaccount?ref=0.9.6"
  namespace          = var.namespace
  kubernetes_cluster = var.kubernetes_cluster
  serviceaccount_name  = "hmpps-portfolio-management"
  github_environments = [var.environment]
  github_repositories = ["hmpps-service-catalogue", "hmpps-health-ping", "hmpps-developer-portal"]
  serviceaccount_token_rotated_date = time_rotating.weekly.unix
}

resource "time_rotating" "weekly" {
  rotation_days = 7
}