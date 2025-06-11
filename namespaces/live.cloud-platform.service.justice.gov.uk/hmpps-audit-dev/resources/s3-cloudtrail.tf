module "cloudtrail_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"

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
}

# Resource to avoid error "AccessControlListNotSupported: The bucket does not allow ACLs"
resource "aws_s3_bucket_ownership_controls" "cloudtrail_bucket_ownership_controls" {
  bucket = module.cloudtrail_s3_bucket.bucket_name
  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_logs" {
  bucket = module.cloudtrail_s3_bucket.bucket_name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:PutObject",
        Resource = "${module.cloudtrail_s3_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      },
      {
        Sid    = "AWSCloudTrailGetBucketAcl",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action   = "s3:GetBucketAcl",
        Resource = module.cloudtrail_s3_bucket.arn
      }
    ]
  })
}

resource "aws_cloudtrail" "s3_data_trail" {
  name                          = "s3-object-events-${var.namespace}"
  s3_bucket_name                = module.cloudtrail_s3_bucket.bucket_name
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = false

    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::${module.s3.bucket_name}/"]
    }
  }

  tags = {
    Environment = var.environment-name
    Terraform   = "true"
  }

  depends_on = [
    aws_s3_bucket_policy.cloudtrail_logs,
    aws_s3_bucket_ownership_controls.cloudtrail_bucket_ownership_controls
  ]
}

data "aws_caller_identity" "current" {}
