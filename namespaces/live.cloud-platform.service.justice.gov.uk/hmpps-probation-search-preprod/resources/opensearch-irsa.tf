# Add iam:PassRole permissions to the IAM role used by the OpenSearch proxy's service account.
# This allows us to pass the SageMaker/Bedrock roles to OpenSearch while creating the connector via the proxy pods.
data "aws_arn" "opensearch_irsa_role" {
  arn = module.opensearch.irsa_role_arn
}

resource "aws_iam_role_policy" "opensearch_connector_irsa_policy" {
  role = trimprefix(data.aws_arn.opensearch_irsa_role.resource, "role/")
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          aws_iam_role.sagemaker_role.arn,
          aws_iam_role.bedrock_role.arn,
        ]
      }
    ]
  })
}
