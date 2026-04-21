module "secrets_kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "2.2.1"

  aliases                 = ["${var.namespace}-secrets"]
  description             = "KMS key for ${var.application} secrets"
  deletion_window_in_days = 7
}

resource "aws_kms_key_policy" "key_policy" {
  key_id = module.secrets_kms.key_id
  policy = jsonencode({
    Id = "example"
    Statement = [
      {
        "Sid": "Default",
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::754256621582:root"
        },
        "Action": "kms:*",
        "Resource": "*"
      },
      {
        "Sid": "Allow use of the key for modernisation platform ",
        "Effect": "Allow",
        "Principal": {
            "AWS": "arn:aws:iam::953751538119:root"
        },
        "Action": [
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:DescribeKey"
        ],
        "Resource": "*"
    },
    # { TODO test if required for GET access.
    #     "Sid": "Allow reading of key metadata",
    #     "Effect": "Allow",
    #     "Principal": {
    #         "AWS": "arn:aws:iam::953751538119:root"
    #     },
    #     "Action": "kms:DescribeKey",
    #     "Resource": "*"
    # },
    # {
    #     "Sid": "Allow attachment of persistent resources",
    #     "Effect": "Allow",
    #     "Principal": {
    #         "AWS": "arn:aws:iam::953751538119:root"
    #     },
    #     "Action": [
    #         "kms:CreateGrant",
    #         "kms:ListGrants",
    #         "kms:RevokeGrant"
    #     ],
    #     "Resource": "*"
    # }
    ]
    Version = "2012-10-17"
  })
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
