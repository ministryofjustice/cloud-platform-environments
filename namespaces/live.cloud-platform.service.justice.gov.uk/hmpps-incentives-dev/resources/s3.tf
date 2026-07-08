module "analytical_platform_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  bucket_policy = data.aws_iam_policy_document.bucket-policy.json

  providers = {
    aws = aws.london
  }
}

locals {
  bucket_arn = "arn:aws:s3:::cloud-platform-280508bd289f5ea3cf77c019c927e693"
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
    bucket_arn  = module.analytical_platform_s3_bucket.bucket_arn
    bucket_name = module.analytical_platform_s3_bucket.bucket_name
  }
}
