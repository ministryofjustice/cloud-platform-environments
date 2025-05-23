data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "s3_access_policy" {

  statement {
    sid = "AllowUserToReadAndWriteS3"
    actions = [
      "s3:*",
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "random_id" "user_id" {
  byte_length = 16
}

resource "aws_iam_user" "s3_user" {
  name = "s3-bucket-user-${random_id.user_id.hex}"
  path = "/system/s3-bucket-user/"
}

resource "aws_iam_access_key" "s3_user" {
  user = aws_iam_user.s3_user.name
}

resource "aws_iam_user_policy" "s3_user_policy" {
  name   = "s3-read-write-policy"
  policy = data.aws_iam_policy_document.s3_access_policy.json
  user   = aws_iam_user.s3_user.name
}
