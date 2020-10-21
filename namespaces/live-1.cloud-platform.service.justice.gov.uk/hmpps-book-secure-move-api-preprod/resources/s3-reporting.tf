/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/main/example
 */
module "book_a_secure_move_reporting_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.5"

  team_name              = var.team_name
  business-unit          = "Digital and Technology"
  application            = var.application
  infrastructure-support = var.infrastructure-support

  is-production    = var.is-production
  environment-name = var.environment-name
  namespace        = var.namespace

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "book_a_secure_move_reporting_s3_bucket" {
  metadata {
    name      = "book-a-secure-move-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.book_a_secure_move_reporting_s3_bucket.access_key_id
    secret_access_key = module.book_a_secure_move_reporting_s3_bucket.secret_access_key
    bucket_arn        = module.book_a_secure_move_reporting_s3_bucket.bucket_arn
    bucket_name       = module.book_a_secure_move_reporting_s3_bucket.bucket_name
  }
}


# Generate an additional IAM user with read-only access to the bucket
resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "s3-bucket-user-${random_id.id.hex}"
  path = "/system/s3-bucket-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]

    resources = [
      module.book_a_secure_move_reporting_s3_bucket.bucket_arn
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
    ]

    resources = [
      "${module.book_a_secure_move_reporting_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket-read-only"
  policy = data.aws_iam_policy_document.policy.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "book_a_secure_move_reporting_s3_bucket_ro" {
  metadata {
    name      = "book-a-secure-move-reporting-s3-bucket-ro"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
    bucket_arn        = module.book_a_secure_move_reporting_s3_bucket.bucket_arn
    bucket_name       = module.book_a_secure_move_reporting_s3_bucket.bucket_name
  }
}
