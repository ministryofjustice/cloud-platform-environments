resource "aws_api_gateway_resource" "role_assume" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "token"
}

resource "aws_api_gateway_method" "role_assume_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.role_assume.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "sts_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.role_assume.id
  type                    = "AWS"
  http_method             = aws_api_gateway_method.role_assume_method.http_method
  integration_http_method = aws_api_gateway_method.role_assume_method.http_method
  uri                     = "arn:aws:apigateway:us-east-1:sts:action/AssumeRole"
  credentials             = aws_iam_role.sts_integration.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  request_templates = {
    "application/json" = <<-EOT
    Action=AssumeRole
    &DurationSeconds=3600
    &RoleArn=arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.namespace}-sqs
    &RoleSessionName=$context.extendedRequestId
    &Tags.member.1.Key=ClientId
    &Tags.member.1.Value=$context.identity.clientCert.subjectDN.replaceAll('.*,CN=', '')
    &Version=2011-06-15
    EOT
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
}

resource "aws_iam_role" "sts_integration" {
  name = "${var.namespace}-sts"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "AllowApiGatewayToAssume"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = ["sts:AssumeRole"],
          Effect = "Allow"
          Sid    = "AllowClientToAssumeSqsRole"
          Resource = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${var.namespace}-sqs"]
        }
      ]
    })
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
        ]
        Effect = "Allow"
        Sid    = "AllowIntegrationRoleToAssume"
        Principal = {
          AWS = aws_iam_role.sts_integration.arn
        }
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        for client, queue_name in local.client_queues :
        {
          Action = [
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:PurgeQueue",
            "sqs:ReceiveMessage",
          ],
          Effect = "Allow"
          Sid    = "${client}-to-sqs"
          Resource = ["arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${queue_name}"]
          Condition = {
            StringEquals = {
              "aws:PrincipalTag/ClientId" = client
            }
          }
        }
      ]
    })
  }
}
