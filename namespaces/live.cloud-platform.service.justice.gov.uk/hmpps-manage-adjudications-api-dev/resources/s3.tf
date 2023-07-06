
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
  bucket_policy          = data.aws_iam_policy_document.bucket-policy.json

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "bucket-policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = [module.analytical-platform.aws_iam_role_arn]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "arn:aws:s3:::cloud-platform-403569db5b294899ffe32e696b1c4ab1/*"
    ]
  }
}

resource "aws_iam_policy" "analytical-platform" {
  name   = "${var.namespace}-analytical-platform"
  policy = data.aws_iam_policy_document.bucket-policy.json
  # NB: IAM policy name must be unique within Cloud Platform

  tags = {
    business-unit          = var.business_unit
    team_name              = var.team_name
    application            = var.application
    is-production          = var.is_production
    namespace              = var.namespace
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}


resource "kubernetes_secret" "analytical-platform" {
  metadata {
    name      = "analytical-platform-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.analytical_platform_s3_bucket.bucket_arn
    bucket_name       = module.analytical_platform_s3_bucket.bucket_name
  }
}
