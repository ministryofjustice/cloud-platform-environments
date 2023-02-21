data "aws_iam_policy_document" "aws_costs" {
  statement {
    sid = "AllowCostExplorer"
    actions = [
      "ce:GetCostAndUsage",
    ]
    resources = ["*"]
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "cp-metrics-aws-costs-${random_id.id.hex}"
  path = "/system/cp-metrics-aws-costs/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "${var.namespace}-aws-costs-policy"
  policy = data.aws_iam_policy_document.aws_costs.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "cp_metrics_aws_costs" {
  metadata {
    name      = "cp-metrics-aws-costs"
    namespace = var.namespace
  }

  data = {
    user_arn          = aws_iam_user.user.arn
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
  }
}