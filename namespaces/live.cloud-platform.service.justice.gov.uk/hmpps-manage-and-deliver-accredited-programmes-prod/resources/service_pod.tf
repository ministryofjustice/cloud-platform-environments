# Service pod for debugging — provides shell access with irsa-sqlserver permissions.
# Useful for manual S3 ls, aws rds commands, and ad-hoc troubleshooting.
module "sqlserver_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.1"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa-sqlserver.service_account.name
}

