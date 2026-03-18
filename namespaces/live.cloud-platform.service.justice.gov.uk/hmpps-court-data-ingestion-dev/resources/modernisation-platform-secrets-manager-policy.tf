
resource "aws_iam_policy" "modernisation_platform_secret_manager_policy" {
  name        = "modernisation-platform-secret-manager-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:eu-west-2:953751538119:secret:ingestion-api-auth-token-olmeRm"
      }
    ]
  })
}

resource "kubernetes_secret" "modernisation_platform_secret_manager" {
  metadata {
    name      = "secret-manager-modernisation-platform"
    namespace = var.namespace
  }

  data = {
    secret_id  = "arn:aws:secretsmanager:eu-west-2:953751538119:secret:ingestion-api-auth-token-olmeRm"
  }
}