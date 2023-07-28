# Generate an IAM user with write-only access to AP bucket
resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "s3-ap-bucket-user-${random_id.id.hex}"
  path = "/system/s3-bucket-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

data "aws_iam_policy_document" "policy" {
  statement {
    sid = "AllowUserListBucket"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::moj-reg-dev"
    ]
  }

  statement {
    sid = "AllowUserWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl"
    ]

    resources = [
      "arn:aws:s3:::moj-reg-dev/landing/hmpps-book-secure-move-api-dev/data/*",
      "arn:aws:s3:::moj-reg-dev/landing/hmpps-book-secure-move-api-dev/data/"
    ]
  }
}

resource "aws_iam_user_policy" "policy" {
  name   = "s3-bucket-write-only"
  policy = data.aws_iam_policy_document.policy.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "book_a_secure_move_ap_user" {
  metadata {
    name      = "book-a-secure-move-ap-user"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
  }
}
