module "secret_ingestion_api_auth_token" {
  source  = "terraform-aws-modules/secrets-manager/aws"
  version = "1.3.1"

  name        = "${var.namespace}-hmac-token"
  description = "Shared secret/token used by the MP Lambda Authorizer to verify incoming requests."
  kms_key_id  = module.secrets_kms.key_id

  ignore_secret_changes = true
  secret_string         = "populate-manually"
}

data "aws_iam_policy_document" "secret_ingestion_api_auth_token_policy_data" {
  statement {
    sid    = "AllowCrossAccountAccess"
    effect = "Allow"

    principals {
      type = "AWS"
      identifiers = [
        var.modernisation_platform_autorizer_lambda
      ]
    }

    actions = [
      "secretsmanager:GetSecretValue"
    ]

    resources = ["*"]
  }
}

resource "aws_secretsmanager_secret_policy" "secret_ingestion_api_auth_token_policy" {
  secret_arn = module.secret_ingestion_api_auth_token.secret_arn
  policy     = data.aws_iam_policy_document.secret_ingestion_api_auth_token_policy_data.json
}


resource "aws_iam_policy" "secret_ingestion_api_auth_token_irsa_policy" {
  name        = "${var.namespace}-secret-auth-irsa-policy"

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
        Resource = module.secret_ingestion_api_auth_token.secret_arn
      }
    ]
  })
}

resource "kubernetes_secret" "secret_ingestion_api_auth_token" {
  metadata {
    name      = "secret-manager-hmac-auth"
    namespace = var.namespace
  }

  data = {
    secret_id  = module.secret_ingestion_api_auth_token.secret_arn
  }
}