# --------------------------------------------------------
# IAM USER FOR LOCAL DATA SCIENCE ACCESS (Read/Download)
# --------------------------------------------------------
resource "random_id" "data_science_user_id" {
  byte_length = 16
}

resource "aws_iam_user" "data_science_user" {
  name = "data-science-s3-user-${random_id.data_science_user_id.hex}"
  path = "/system/data-science-s3-user/"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_iam_access_key" "data_science_user" {
  user = aws_iam_user.data_science_user.name
}

data "aws_iam_policy_document" "data_science_s3_read_access" {
  statement {
    sid = "AllowListBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      module.s3_bucket.bucket_arn
    ]
  }

  statement {
    sid = "AllowReadObjects"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetObjectTagging"
    ]
    resources = [
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "data_science_s3_read_policy" {
  name   = "data-science-s3-read-policy"
  policy = data.aws_iam_policy_document.data_science_s3_read_access.json
  user   = aws_iam_user.data_science_user.name
}

resource "kubernetes_secret" "data_science_s3_credentials" {
  metadata {
    name      = "data-science-s3-credentials"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.s3_bucket.bucket_arn
    bucket_name       = module.s3_bucket.bucket_name
    access_key_id     = aws_iam_access_key.data_science_user.id
    secret_access_key = aws_iam_access_key.data_science_user.secret
  }
}
