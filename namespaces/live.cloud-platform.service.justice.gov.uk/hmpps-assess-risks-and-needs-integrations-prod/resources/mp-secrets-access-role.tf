# CP intermediary IAM role for accessing the Modernisation Platform secret
# This role is assumed by the manager-concourse user (intra-account, no SCP issue).
# The MP team must add a resource-based policy on the secret to allow this role ARN:

resource "aws_iam_role" "mp_secrets_access" {
  name        = "arns-${var.environment}-mp-secrets-access"
  description = "Intermediary role for Terraform to read MP secrets at provision time"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowConcourseToAssume"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::754256621582:user/cloud-platform/manager-concourse"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_iam_policy" "mp_secrets_read" {
  name        = "arns-${var.environment}-mp-secrets-read"
  description = "Allows reading the DPR cross-account secret from the Modernisation Platform"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadAndUpdateMPSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:PutSecretValue",
          "secretsmanager:UpdateSecret"
        ]
        Resource = [
          "arn:aws:secretsmanager:eu-west-2:004723187462:secret:external/dpr-pr-assessment-view-source-secrets-*"
        ]
      },
      {
        Sid    = "UseMPKMSKeyForSecret"
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey"
        ]
        Resource = "arn:aws:kms:eu-west-2:004723187462:key/*"
      }
    ]
  })

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_iam_role_policy_attachment" "mp_secrets_read" {
  role       = aws_iam_role.mp_secrets_access.name
  policy_arn = aws_iam_policy.mp_secrets_read.arn
}
