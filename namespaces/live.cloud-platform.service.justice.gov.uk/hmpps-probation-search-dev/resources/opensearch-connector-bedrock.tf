resource "aws_iam_role" "bedrock_role" {
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
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
            "aws:SourceArn"     = module.opensearch.domain_arn
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "bedrock_policy" {
  role = aws_iam_role.bedrock_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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
