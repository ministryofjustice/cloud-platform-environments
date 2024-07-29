data "kubernetes_secret" "indexer_secret" {
  metadata {
    name      = "person-search-index-from-delius-opensearch"
    namespace = var.namespace
  }
}

resource "aws_iam_policy" "opensearch_bedrock_connector_management_policy" {
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = data.kubernetes_secret.indexer_secret.data.bedrock_role_arn
      }
    ]
  })
}