# -----------------------------------------------------------------------------
# 1. NEW LOGGING TARGET BUCKET
# -----------------------------------------------------------------------------
resource "random_id" "s3_logging_bucket_suffix" {
  byte_length = 16
}

locals {
  s3_logging_bucket_name = "cloud-platform-${random_id.s3_logging_bucket_suffix.hex}"

  s3_logging_bucket_tags = {
    "business-unit"          = var.business_unit
    "application"             = var.application
    "is-production"           = var.is_production
    "environment-name"        = var.environment
    "infrastructure-support"  = var.infrastructure_support
    "namespace"               = var.namespace
    "owner"                   = var.team_name
  }
}

resource "aws_s3_bucket" "s3_logging_bucket" {
  bucket        = local.s3_logging_bucket_name
  force_destroy = true

  tags = local.s3_logging_bucket_tags
}

resource "aws_s3_bucket_public_access_block" "s3_logging_bucket" {
  bucket = aws_s3_bucket.s3_logging_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CRITICAL: Pre-requisite for ACLs in post-April 2023 AWS accounts
resource "aws_s3_bucket_ownership_controls" "s3_logging_bucket" {
  bucket = aws_s3_bucket.s3_logging_bucket.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# CRITICAL: Allows S3 delivery log writes
resource "aws_s3_bucket_acl" "s3_logging_bucket" {
  bucket = aws_s3_bucket.s3_logging_bucket.id
  acl    = "log-delivery-write"

  depends_on = [
    aws_s3_bucket_ownership_controls.s3_logging_bucket,
    aws_s3_bucket_public_access_block.s3_logging_bucket,
  ]
}

# -----------------------------------------------------------------------------
# 2. PRIMARY S3 BUCKET
# -----------------------------------------------------------------------------
module "s3_bucket" {
  # Always check for the latest release tag in cloud-platform-terraform-s3-bucket
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  versioning = true

  # Logging configuration
  logging_enabled   = true
  log_target_bucket = aws_s3_bucket.s3_logging_bucket.id
  log_path          = "s3-access-logs/"

  # GitHub Actions OIDC integration
  oidc_providers      = ["github"]
  github_repositories = ["justice-redact-frontend", "justice-redact-backend"]
  github_environments = ["dev"]
}

# -----------------------------------------------------------------------------
# 3. KUBERNETES OUTPUT SECRET
# -----------------------------------------------------------------------------
resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }

  type = "Opaque"
}