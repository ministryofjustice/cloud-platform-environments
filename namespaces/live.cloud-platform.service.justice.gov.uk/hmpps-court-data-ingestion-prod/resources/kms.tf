module "secrets_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.2.1"

  aliases                 = ["${var.namespace}-secrets"]
  description             = "KMS key for ${var.application} secrets"
  deletion_window_in_days = 7

  key_statements = [
    {
      sid = "AllowModernisationPlatformDecrypt"
      actions = [
        "kms:Decrypt"
      ]
      principals = [
        {
          type        = "AWS"
          identifiers = [var.modernisation_platform_autorizer_lambda]
        }
      ]
      resources = ["*"]
    }
  ]
}


resource "aws_iam_policy" "secret_ingestion_api_auth_token_kms_irsa_policy" {
  name        = "${var.namespace}-secret-auth-kms-irsa-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:CreateGrant",
          "kms:DescribeKey",
          "kms:GenerateDataKey*"

        ]
        Resource = module.secrets_kms.key_arn
      }
    ]
  })
}
