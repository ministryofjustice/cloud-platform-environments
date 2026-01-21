data "aws_caller_identity" "current" {}

# Generate an additional IAM user to manage API Gateway
resource "random_id" "api_gateway_id" {
  byte_length = 16
}

resource "aws_iam_user" "api_gateway_user" {
  name = "api-gateway-user-${random_id.api_gateway_id.hex}"
  path = "/system/api-gateway-user/"
}

resource "aws_iam_access_key" "api_gateway_user" {
  user = aws_iam_user.api_gateway_user.name
}

data "aws_iam_policy_document" "api_gateway" {
  statement {
    actions = [
      "apigateway:GET",
    ]

    resources = [
      "${element(split("/", aws_api_gateway_rest_api.api_gateway.arn), 0)}/*",
    ]
  }

  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = [
      module.certificate_backup.bucket_arn
    ]
  }

}

resource "aws_iam_user_policy" "api_gateway_policy" {
  name   = "${var.namespace}-api-gateway"
  policy = data.aws_iam_policy_document.api_gateway.json
  user   = aws_iam_user.api_gateway_user.name
}

resource "aws_iam_role" "api_gateway_role" {
  name               = "${var.namespace}-api-gateway"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "api_gw_s3" {
  name = "${var.namespace}-api-gateway-s3"
  role = aws_iam_role.api_gateway_role.name

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": "s3:GetObject",

      "Resource": [
        "${module.truststore_s3_bucket.bucket_arn}/*"
      ]
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "${var.namespace}-default"
  role   = aws_iam_role.api_gateway_role.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}


data "aws_iam_policy_document" "secrets_manager_access" {
  statement {
    actions = [
      "secretsmanager:Get*",
      "secretsmanager:PutSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:eu-west-2:754256621582:secret:live-hmpps-integration-api-preprod-*-*"
    ]
  }
}

resource "aws_iam_policy" "secrets_manager_access" {
  name   = "${var.namespace}-secretsmanager-access"
  policy = data.aws_iam_policy_document.secrets_manager_access.json

  tags = {
    business_unit          = var.business_unit
    application            = var.application
    is_production          = var.is_production
    team_name              = var.team_name
    environment_name       = var.environment
    infrastructure_support = var.infrastructure_support
  }
}

resource "aws_iam_role" "sqs" {
  name = "${var.namespace}-sqs"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ],
        Effect = "Allow"
        Sid    = "AllowApiGatewayStsIntegrationToAssume"
        Principal = {
          AWS = aws_iam_role.sts_integration.arn
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "sqs" {
  for_each = local.client_queues
  name     = "${var.namespace}-${each.key}-sqs"
  role     = aws_iam_role.sqs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:PurgeQueue",
          "sqs:ReceiveMessage",
        ],
        Effect = "Allow"
        Sid    = "AccessQueue"
        Resource = ["arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${each.value}"]
        Condition = {
          StringEquals = {
            "aws:PrincipalTag/ClientId" = each.key
          }
        }
      },
    ]
  })
}
