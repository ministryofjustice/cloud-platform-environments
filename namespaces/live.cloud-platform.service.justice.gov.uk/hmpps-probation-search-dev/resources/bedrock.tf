resource "aws_iam_role" "opensearch_bedrock_role" {
  name = "${var.namespace}-opensearch-bedrock-connector"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "opensearchservice.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "opensearch_bedrock_policy" {
  role = aws_iam_role.opensearch_bedrock_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = aws_iam_role.opensearch_bedrock_role.arn
      },
      {
        Effect   = "Allow",
        Action   = "es:ESHttpPost",
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "bedrock:InvokeModel",
          "bedrock:Get*",
          "bedrock:List*",
        ],
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy" "opensearch_bedrock_irsa_policy" {
  role = module.opensearch.irsa_role_arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow",
        Action   = "iam:PassRole",
        Resource = aws_iam_role.opensearch_bedrock_role.arn
      }
    ]
  })
}
