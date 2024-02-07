module "hmpps-prisoner-location_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = { aws = aws.london }

  lifecycle_rule = [
    {
      enabled    = true
      id         = "expire all locations after 14 days"
      expiration = [{ days = 14 }]
    },
  ]
}

data "aws_iam_policy_document" "dso_user_s3_access_policy" {
  statement {
    sid    = "AllowDsoUserToReadAndPutObjectsInS3"
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:ListBucket",
      "kms:Encrypt",
      "kms:GenerateDataKey"
    ]

    resources = [
      "${module.hmpps-prisoner-location_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user" "user" {
  name = "dso-s3-pl-access-user-${var.environment}"
  path = "/system/dso-s3-pl-access-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "dso-s3-pl-read-write-policy"
  policy = data.aws_iam_policy_document.dso_user_s3_access_policy.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "hmpps-prisoner-location_s3_bucket" {
  metadata {
    name      = "hmpps-prisoner-location-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.hmpps-prisoner-location_s3_bucket.bucket_arn
    bucket_name = module.hmpps-prisoner-location_s3_bucket.bucket_name

    dso_s3_access_user_arn   = aws_iam_user.user.arn
    dso_s3_access_key_id     = aws_iam_access_key.user.id
    dso_s3_secret_access_key = aws_iam_access_key.user.secret
  }
}
