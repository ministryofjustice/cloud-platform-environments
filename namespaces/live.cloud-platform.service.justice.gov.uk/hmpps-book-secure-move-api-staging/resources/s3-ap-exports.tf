# Generate an IAM user with write-only access to AP bucket
resource "random_id" "ap-id" {
  byte_length = 16
}

resource "aws_iam_user" "ap-user" {
  name = "s3-ap-bucket-user-${random_id.ap-id.hex}"
  path = "/system/s3-bucket-user/"
}

resource "aws_iam_access_key" "ap-user" {
  user = aws_iam_user.ap-user.name
}

data "aws_iam_policy_document" "ap-policy" {
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

resource "aws_iam_user_policy" "ap-policy" {
  name   = "s3-bucket-write-only"
  policy = data.aws_iam_policy_document.ap-policy.json
  user   = aws_iam_user.ap-user.name
}

resource "kubernetes_secret" "book_a_secure_move_ap_user" {
  metadata {
    name      = "book-a-secure-move-ap-user"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.ap-user.id
    secret_access_key = aws_iam_access_key.ap-user.secret
  }
}
