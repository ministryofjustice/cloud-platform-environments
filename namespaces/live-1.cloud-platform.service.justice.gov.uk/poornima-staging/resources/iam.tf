resource "aws_iam_user" "read_bucket_user" {
  name = "poornima-staging-read-test-bucket-user"
  path = "/system/poornima-staging-read-bucket-users/"
}

resource "aws_iam_access_key" "read_bucket_user_key" {
  user = aws_iam_user.read_bucket_user.name
}

data "aws_iam_policy_document" "read_bucket_user_policy" {
  statement {
    actions = ["s3:GetObject"]

    resources = [
      "${module.test_s3_bucket.bucket_arn}/*"
    ]
  }

  statement {
    effect = "Deny"

    actions = ["s3:*"]

    resources = [
      "${module.test_s3_bucket.bucket_arn}",
      "${module.test_s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_user_policy" "read_bucket_user_policy" {
  name   = "poornima-staging-read-bucket-user-policy"
  policy = data.aws_iam_policy_document.read_bucket_user_policy.json
  user   = aws_iam_user.read_bucket_user.name
}

resource "kubernetes_secret" "read_bucket_user" {
  metadata {
    name      = "test-read-bucket-user"
    namespace = var.namespace
  }

  data = {
    read_bucket_user_arn               = aws_iam_user.read_bucket_user.arn
    read_bucket_user_access_key_id     = aws_iam_access_key.read_bucket_user_key.id
    read_bucket_user_secret_access_key = aws_iam_access_key.read_bucket_user_key.secret
  }
}

