# Justice Redact evaluation data is written to the Analytical Platform
# application S3 bucket by workloads using IRSA and STS AssumeRole.
#
# The Secret is retained temporarily for compatibility with the currently
# deployed data-extractor CronJob, which reads only destination_bucket.
# New deployments should use the ConfigMap instead.

locals {
  ap_s3_role_arn = "arn:aws:iam::${var.ap_account_id}:role/alpha_app_justice-redact-backend"
}

resource "kubernetes_config_map" "ap_data_export" {
  metadata {
    name      = "analytical-platform-data-export"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://alpha-app-justice-redact-dev/"
    ap_s3_role_arn      = local.ap_s3_role_arn
  }
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://alpha-app-justice-redact-dev/"
  }
}