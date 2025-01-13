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
