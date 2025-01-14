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
        Resource = aws_iam_role.cross_account_pass_role.arn
      }
    ]
  })
}

## Role to allow passing a role OpenSearch in Account A (Cloud Platform account) to assume a role and invoke SageMaker in Account B (Analytical Platform Compute account on Modernisation Platform)
## See https://github.com/opensearch-project/ml-commons/blob/f741f71fff0d2ef6df7a3a62729cc1cb0953a37c/docs/tutorials/aws/semantic_search_with_bedrock_titan_embedding_model_in_another_account.md
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
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "AllowToAssumeRemoteRole"
          Effect   = "Allow"
          Action   = "sts:AssumeRole"
          Resource = local.opensearch_connector_role_arn
        }
      ]
    })
  }
}
