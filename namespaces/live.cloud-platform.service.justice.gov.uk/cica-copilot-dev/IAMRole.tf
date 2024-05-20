terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_iam_role" "cloud_platform_role" {
  name = "CloudPlatformToModPlatformAccess"
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
  name   = "FullAccessBedrockService"
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "bedrock:*",
      "Resource": "*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "attach_bedrock_policy" {
  role       = aws_iam_role.cloud_platform_role.name
  policy_arn = aws_iam_policy.access_bedrock_service.arn
}
