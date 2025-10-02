# Destination bucket for S3 Inventory reports
module "s3_inventory_reports" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  logging_enabled        = false
}

# (Recommended) ownership controls so S3's ACLs land as bucket-owner
resource "aws_s3_bucket_ownership_controls" "s3_inventory_reports" {
  bucket = module.s3_inventory_reports.bucket_name
  rule { object_ownership = "BucketOwnerPreferred" }
}

# Allow the SOURCE bucket's account to put inventory objects with the expected ACL
resource "aws_s3_bucket_policy" "s3_inventory_reports" {
  bucket = module.s3_inventory_reports.bucket_name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid : "AllowInventoryWrite",
        Effect : "Allow",
        Principal : { "Service" : "s3.amazonaws.com" },
        Action : ["s3:PutObject", "s3:PutObjectAcl"],
        Resource : "${module.s3_inventory_reports.bucket_arn}/${var.inventory_prefix}/*",
        Condition : { StringEquals : { "s3:x-amz-acl" : "bucket-owner-full-control" } }
      },
      {
        Sid : "AllowGetBucketAcl",
        Effect : "Allow",
        Principal : { AWS : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root" },
        Action : ["s3:GetBucketAcl"],
        Resource : module.s3_inventory_reports.bucket_arn
      }
    ]
  })
}

# S3 Inventory from your Alfresco content bucket -> destination bucket
resource "aws_s3_bucket_inventory" "alfresco_s3_inventory_daily" {
  bucket                   = module.s3_bucket.bucket_name # source (your content bucket)
  name                     = "alfresco-${var.environment_name}-daily-inventory"
  included_object_versions = "Current" # use "All" if you want version-level rows
  schedule {
    frequency = "Daily"
  }
  enabled = true

  destination {
    bucket {
      bucket_arn = module.s3_inventory_reports.bucket_arn
      format     = "Parquet"
      prefix     = var.inventory_prefix
    }
  }

  optional_fields = [
    "Size", "ETag", "StorageClass", "LastModifiedDate", "EncryptionStatus"
  ]
}
