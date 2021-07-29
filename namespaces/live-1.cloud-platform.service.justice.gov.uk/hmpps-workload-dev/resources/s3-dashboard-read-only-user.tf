# This IAM user enables operations engineering projects to use the S3 bucket
# and dynamodb defined here to implement terraform state-locking. It is
# required because the cloud platform S3 and DynamoDB modules both create
# dedicated IAM users with access to their specific, single resource, but we
# need an IAM user with access to both resources.

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

resource "kubernetes_secret" "dashboard-read-only-user-secret" {
  metadata {
    name      = "dashboard-read-only-user-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
  }
}

data "aws_iam_policy_document" "policy" {

  statement {
    actions = [
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      "${module.hmpps-workload-dev-s3-dashboard-bucket.bucket_arn}/*",
      "${module.hmpps-workload-dev-s3-dashboard-bucket.bucket_arn}"
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket-read-only"
  policy = data.aws_iam_policy_document.policy.json
  user   = aws_iam_user.user.name
}