module "s3_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa-cronjob.service_account.name # this uses the service account name from the irsa module
}

/*module "sqlserver_rds_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa-sqlserver.service_account.name # this uses the service account name from the irsa module
}*/

# APG-2664: service pod bound to irsa-sqlserver — needed for the post-merge runbook
# step that copies the final .bak from sqlserver_backup_s3_bucket to archive_s3_bucket.
# irsa-sqlserver gets archive_s3_bucket_policy in irsa.tf (write access to archive) and
# already has sqlserver_backup_s3_bucket_policy (read access to source bucket).
module "sqlserver_rds_service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.3.0"

  namespace            = var.namespace
  service_account_name = module.irsa-sqlserver.service_account.name
}