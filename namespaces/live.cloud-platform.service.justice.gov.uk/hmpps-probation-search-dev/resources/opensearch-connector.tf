locals {
  opensearch_connector_role_arn = "arn:aws:iam::${var.analytical_platform_compute_account_id}:role/probation-search-sagemaker-role"
}

data "aws_arn" "opensearch_irsa_role" {
  arn = module.opensearch.irsa_role_arn
}

resource "aws_iam_role_policy" "opensearch_connector_irsa_policy" {
  role = trimprefix(data.aws_arn.opensearch_irsa_role.resource, "role/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = local.opensearch_connector_role_arn
      }
    ]
  })
}

## Role to allow passing a role from Account A (Modernisation Platform) to Account B (Cloud Platform)
## See https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_passrole.html#:~:text=To%20pass%20a%20role%20in%20Account%20A%20to%20a%20service%20in%20Account%20B%2C%20you%20must%20first%20create%20an%20IAM%20role%20in%20Account%20B%20that%20can%20assume%20the%20role%20from%20Account%20A%2C%20and%20then%20the%20role%20in%20Account%20B%20can%20be%20passed%20to%20the%20service
resource "aws_iam_role" "cross_account_pass_role" {
  name = "${var.namespace}-xa-opensearch-to-sagemaker"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowOpenSearchServiceToAssume"
        Effect = "Allow"
        Principal = {
          Service = "opensearchservice.amazonaws.com"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = "754256621582"
          }
        }
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid    = "AllowToAssumeRemoteRole"
          Effect = "Allow"
          Action = [
            "sts:AssumeRole",
            "sts:TagSession",
          ]
          Resource = local.opensearch_connector_role_arn
        }
      ]
    })
  }
}
