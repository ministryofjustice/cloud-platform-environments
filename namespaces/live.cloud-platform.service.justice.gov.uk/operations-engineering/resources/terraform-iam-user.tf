# This IAM user enables operations engineering projects to use the S3 bucket
# and dynamodb defined here to implement terraform state-locking. It is
# required because the cloud platform S3 and DynamoDB modules both create
# dedicated IAM users with access to their specific, single resource, but we
# need an IAM user with access to both resources.

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "terraform_user" {
  name = "terraform-user-${random_id.id.hex}"
  path = "/system/opseng-terraform-user/"
}

resource "aws_iam_access_key" "terraform_user" {
  user = aws_iam_user.terraform_user.name
}

resource "kubernetes_secret" "terraform_user_secret" {
  metadata {
    name      = "terraform-user-aws-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.terraform_user.id
    secret_access_key = aws_iam_access_key.terraform_user.secret
  }
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
      module.s3_bucket.bucket_arn
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "dynamodb:*",
    ]

    resources = [
      module.opseng_tf_state_lock.table_arn
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket-and-dynamodb"
  policy = data.aws_iam_policy_document.policy.json
  user   = aws_iam_user.terraform_user.name
}
