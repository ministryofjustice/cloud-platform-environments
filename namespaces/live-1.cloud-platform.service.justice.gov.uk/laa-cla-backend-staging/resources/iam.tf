resource "random_id" "laa-cla-end-to-end-id" {
  byte_length = 16
}

resource "aws_iam_user" "laa-cla-end-to-end-user" {
  name = "laa-cla-end-to-end-user-${random_id.laa-cla-end-to-end-id.hex}"
}

resource "aws_iam_access_key" "laa-cla-end-to-end-user" {
  user = aws_iam_user.laa-cla-end-to-end-user.name
}

data "aws_iam_policy_document" "laa-cla-end-to-end" {
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:GetDownloadUrlForLayer",
    ]

    resources = [
      "var.cla-public-ecr-arn"
    ]
  }
}

resource "aws_iam_user_policy" "laa-cla-end-to-end-policy" {
  name   = "laa-cla-end-to-end-policy"
  policy = data.aws_iam_policy_document.laa-cla-end-to-end.json
  user   = aws_iam_user.laa-cla-end-to-end-user.name
}

resource "kubernetes_secret" "laa_cla_end_to_end_user" {
  metadata {
    name      = "laa-cla-end-to-end-ecr-iam"
    namespace = "var.namespace"
  }

  data = {
    access_key_id     = aws_iam_access_key.laa-cla-end-to-end-user.id
    secret_access_key = aws_iam_access_key.laa-cla-end-to-end-user.secret
  }
}
