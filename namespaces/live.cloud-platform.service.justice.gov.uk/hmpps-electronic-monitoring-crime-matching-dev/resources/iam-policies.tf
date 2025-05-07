data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:PutParameter",
      "ssm:DeleteParameter"
    ]
    resources = [
      "arn:aws:ssm:eu-west-2:754256621582:parameter/${var.namespace}/athena_general_role_arn"
    ]
  }
}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.namespace}-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_policy.json
  tags = local.tags
}
