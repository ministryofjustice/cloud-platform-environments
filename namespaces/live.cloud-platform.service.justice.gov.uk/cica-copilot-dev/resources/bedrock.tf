resource "aws_iam_role" "guidance_bedrock_role" {
  name = "${var.namespace}-mod-platform-bedrock-connector"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::321388111150:role/BedrockAccessforCP"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "access_bedrock_service" {
  name   = "AccessBedrockService"
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
        Resource = [
          "arn:aws:bedrock:eu-central-1:321388111150:model/amazon.titan-embed-text-v1",
          "arn:aws:bedrock:eu-central-1:321388111150:model/anthropic.claude-instant-v1",
          "arn:aws:bedrock:eu-central-1:321388111150:model/anthropic.claude-v2:1",
          "arn:aws:bedrock:eu-central-1:321388111150:model/anthropic.claude-v2",
          "arn:aws:bedrock:eu-central-1:321388111150:model/anthropic.claude-3-5-sonnet-20240620-v1:0",          
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_policy" {
  role       = aws_iam_role.guidance_bedrock_role.name
  policy_arn = aws_iam_policy.access_bedrock_service.arn
}
