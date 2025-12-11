/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 */
module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

# --------------------------------------------------------
# BUCKET POLICY (Allow the external user)
# --------------------------------------------------------
data "aws_iam_policy_document" "merged_bucket_policy" {

  statement {
    sid    = "AllowExternalUserToReadAndPutObjectsInS3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.user.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }

    # --- VPCE-restricted ---
  statement {
    sid    = "AllowS3AccessFromVPCE"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.user.arn]
    }

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "StringEquals"
      variable = "aws:SourceVpce"

      values = [
        "vpce-0f82cc8809dc37503"
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "restricted_policy" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.merged_bucket_policy.json
}

# --------------------------------------------------------
# IAM USER FOR EXTERNAL S3 ACCESS
# --------------------------------------------------------
resource "aws_iam_user" "user" {
  name = "external-s3-access-user-${var.environment}"
  path = "/system/external-s3-access-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

# --------------------------------------------------------
# IAM POLICY FOR THAT USER (same permissions as bucket policy)
# --------------------------------------------------------
data "aws_iam_policy_document" "external_user_s3_access_policy" {
  statement {
    sid = "AllowExternalUserToReadAndPutObjectsInS3"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "external-s3-read-write-policy"
  policy = data.aws_iam_policy_document.external_user_s3_access_policy.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn                    = module.s3_bucket.bucket_arn
    bucket_name                   = module.s3_bucket.bucket_name
    external_s3_access_user_arn   = aws_iam_user.user.arn
    external_s3_access_key_id     = aws_iam_access_key.user.id
    external_s3_secret_access_key = aws_iam_access_key.user.secret
  }
}
