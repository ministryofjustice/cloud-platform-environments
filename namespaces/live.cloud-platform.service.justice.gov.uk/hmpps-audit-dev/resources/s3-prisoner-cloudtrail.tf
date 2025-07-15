module "hmpps_prisoner_audit_s3_logging" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  # S3 configuration
  versioning = true
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  bucket_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy",
        Effect = "Allow",
        Principal = {
          Service = "logging.s3.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:GetObject",

        ],
        Resource = "$${bucket_arn}/*"
      }
    ]
  })
}

resource "kubernetes_secret" "hmpps_prisoner_audit_s3_logging" {
  metadata {
    name      = "hmpps_prisoner_audit_s3_logging"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps_prisoner_audit_s3_logging.bucket_arn
    bucket_name = module.hmpps_prisoner_audit_s3_logging.bucket_name
  }
}
