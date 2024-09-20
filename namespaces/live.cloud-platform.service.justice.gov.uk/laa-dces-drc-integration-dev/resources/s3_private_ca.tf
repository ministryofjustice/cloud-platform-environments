module "s3_private_ca_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

  providers = {
    aws = aws.london
  }
}

resource "aws_iam_user" "dces_ca_admin_user_dev" {
  name = "laa-dces-drc-integration-dev-dces-ca-admin_user"
  path = "/system/laa-dces-data-integration-dev-dces-ca-admin_user/"
}

resource "aws_iam_access_key" "dces_ca-admin_user_dev_key" {
  user = aws_iam_user.dces_ca_admin_user_dev.name
}

resource "aws_iam_policy" "policy" {
  name   = "private-ca-policy"
  policy = data.aws_iam_policy_document.ca-policy.json
}

data "aws_iam_policy_document" "ca-policy" {
  statement {
    principals {
      type = "AWS"
      identifiers = [aws_iam_user.dces_ca_admin_user_dev.arn
      ]
    }
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      module.s3_private_ca_bucket.bucket_arn,
      "${module.s3_private_ca_bucket.bucket_arn}/*"
    ]
  }

  statement {
    effect  = "Deny"
    actions = ["s3:*"]
    resources = [
      module.s3_private_ca_bucket.bucket_arn,
      "${module.s3_private_ca_bucket.bucket_arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = ["false"]
    }
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "kubernetes_secret" "s3_private_ca_bucket" {
  metadata {
    name      = "private-integration-ca"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_private_ca_bucket.bucket_arn
    bucket_name = module.s3_private_ca_bucket.bucket_name
  }
}
