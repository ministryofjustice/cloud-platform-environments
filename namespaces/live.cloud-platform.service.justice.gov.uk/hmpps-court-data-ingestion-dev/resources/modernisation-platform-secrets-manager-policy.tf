data "aws_iam_policy_document" "modernisation_platform_secret_manager_policy_data" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = [
        "secretsmanager:GetSecretValue",
        "secretsmanager:PutSecretValue"
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:953751538119:secret:ingestion-api-auth-token-olmeRm"
    ]
  }
}

resource "aws_secretsmanager_secret_policy" "modernisation_platform_secret_manager_policy" {
  secret_arn = "arn:aws:secretsmanager:eu-west-2:953751538119:secret:ingestion-api-auth-token-olmeRm"
  policy     = data.aws_iam_policy_document.modernisation_platform_secret_manager_policy_data.json
}