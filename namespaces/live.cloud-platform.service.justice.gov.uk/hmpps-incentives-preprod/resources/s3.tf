module "analytical_platform_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = data.aws_iam_policy_document.bucket-policy.json

  providers = {
    aws = aws.london
  }
}

locals {
  bucket_arn = "arn:aws:s3:::cloud-platform-1ed50d9e895c5fd29329796e35c3cc10"
}

data "aws_iam_policy_document" "bucket-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [module.analytical-platform.aws_iam_role_arn]
    }
    actions = [
      "s3:ListBucket",
    ]
    resources = [
      local.bucket_arn
    ]
  }
  statement {
    principals {
      type        = "AWS"
      identifiers = [module.analytical-platform.aws_iam_role_arn]
    }
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]
    resources = [
      "${local.bucket_arn}/*"
    ]
  }
}

resource "kubernetes_secret" "analytical_platform_s3_bucket" {
  metadata {
    name      = "analytical-platform-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.analytical_platform_s3_bucket.access_key_id
    secret_access_key = module.analytical_platform_s3_bucket.secret_access_key
    bucket_arn        = module.analytical_platform_s3_bucket.bucket_arn
    bucket_name       = module.analytical_platform_s3_bucket.bucket_name
  }
}
