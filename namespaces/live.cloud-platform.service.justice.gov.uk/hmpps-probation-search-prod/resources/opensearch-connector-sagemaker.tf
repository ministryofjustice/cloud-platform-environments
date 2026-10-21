locals {
  remote_sagemaker_role = "arn:aws:iam::${var.analytical_platform_compute_account_id}:role/${var.namespace}-sagemaker-role"
}

## Role to allow passing a role OpenSearch in Account A (Cloud Platform account) to assume a role and invoke SageMaker in Account B (Analytical Platform Compute account on Modernisation Platform)
## See https://github.com/opensearch-project/ml-commons/blob/f741f71fff0d2ef6df7a3a62729cc1cb0953a37c/docs/tutorials/aws/semantic_search_with_bedrock_titan_embedding_model_in_another_account.md
resource "aws_iam_role" "sagemaker_role" {
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
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = module.opensearch.domain_arn
          }
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "sagemaker_policy" {
  role = aws_iam_role.sagemaker_role.name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowToAssumeRemoteRole"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = local.remote_sagemaker_role
      }
    ]
  })
}
