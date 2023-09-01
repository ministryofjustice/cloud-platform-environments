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
      "s3:List*",
      "s3:Get*",
    ]

    resources = [
      "${module.hmpps-workload-dev-s3-dashboard-bucket.bucket_arn}/*",
      module.hmpps-workload-dev-s3-dashboard-bucket.bucket_arn
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket-read-only"
  policy = data.aws_iam_policy_document.policy.json
  user   = aws_iam_user.user.name
}