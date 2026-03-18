
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
        Resource = var.modernisation_platform_secrets_manager
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
    secret_id  = var.modernisation_platform_secrets_manager
  }
}