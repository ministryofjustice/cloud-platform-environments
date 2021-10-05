# Generate an additional IAM user to internal app
resource "random_id" "paul-internal-id" {
  byte_length = 16
}

resource "aws_iam_user" "paul-internal-user" {
  name = "paul-internal-user-paul"
  path = "/system/paul-internal-user/"
}

resource "aws_iam_access_key" "paul-internal-user" {
  user = aws_iam_user.paul-internal-user.name
}

data "aws_iam_policy_document" "paul-internal" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]

    resources = []
  }
}

resource "aws_iam_user_policy" "paul-internal-policy" {
  name   = "${var.namespace}-paul-internal"
  policy = data.aws_iam_policy_document.paul-internal.json
  user   = aws_iam_user.paul-internal-user.name
}
