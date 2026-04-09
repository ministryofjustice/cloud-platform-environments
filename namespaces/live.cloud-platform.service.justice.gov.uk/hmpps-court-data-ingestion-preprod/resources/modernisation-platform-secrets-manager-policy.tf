
resource "aws_iam_policy" "modernisation_platform_secret_manager_policy" {
  name        = "${var.namespace}-mp-sm-policy"
  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    namespace              = var.namespace
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret"
        ]
        Resource = var.modernisation_platform_secrets_manager
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey",
          "kms:ReEncrypt*",
        ]
        Resource = var.modernisation_platform_secrets_manager_key
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
    key_id     = var.modernisation_platform_secrets_manager_key
  }
}