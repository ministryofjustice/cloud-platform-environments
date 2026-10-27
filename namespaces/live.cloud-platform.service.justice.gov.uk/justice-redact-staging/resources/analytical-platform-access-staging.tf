# Justice Redact staging evaluation data is written to the Analytical Platform
# application S3 bucket by workloads using IRSA and STS AssumeRole.

locals {
  ap_s3_role_arn = "arn:aws:iam::${var.ap_account_id}:role/alpha_app_justice-redact-backend"
}

resource "kubernetes_config_map" "ap_data_export" {
  metadata {
    name      = "analytical-platform-data-export"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://alpha-app-justice-redact-staging/"
    ap_s3_role_arn      = local.ap_s3_role_arn
  }
}