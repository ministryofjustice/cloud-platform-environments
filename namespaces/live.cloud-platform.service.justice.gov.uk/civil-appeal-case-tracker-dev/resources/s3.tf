/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
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
# VPC ENDPOINT FOR S3 BUCKET ACCESS FROM WITHIN VPC
# --------------------------------------------------------
resource "aws_vpc_endpoint" "s3_gateway" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"

  route_table_ids = [
    aws_route_table.private.id,
  ]
}

# --------------------------------------------------------
# BUCKET POLICY (external user + VPC restriction)
# --------------------------------------------------------
data "aws_iam_policy_document" "merged_bucket_policy" {

  # Allow the external user access
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

  # Deny everything unless request used the VPC endpoint
  statement {
    sid    = "DenyUnlessViaVpcEndpoint"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]

    condition {
      test     = "StringNotEquals"
      variable = "aws:SourceVpce"
      values   = [aws_vpc_endpoint.s3_gateway.id]
    }
  }
}

# --------------------------------------------------------
# MERGED POLICY TO THE BUCKET
# --------------------------------------------------------
resource "aws_s3_bucket_policy" "restricted_policy" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.merged_bucket_policy.json
}

# --------------------------------------------------------
# 4. EXTERNAL USER FOR S3 BUCKET ACCESS
# --------------------------------------------------------
resource "aws_iam_user" "user" {
  name = "external-s3-access-user-${var.environment}"
  path = "/system/external-s3-access-user/"
}

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

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
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
