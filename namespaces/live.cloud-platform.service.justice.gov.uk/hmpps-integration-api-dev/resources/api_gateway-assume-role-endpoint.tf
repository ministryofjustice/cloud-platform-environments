resource "aws_api_gateway_resource" "role_assume" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "token"
}

resource "aws_api_gateway_method" "role_assume_method" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.role_assume.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sts_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.role_assume.id
  http_method             = aws_api_gateway_method.role_assume_method.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:sts:action/AssumeRole"

  request_templates = {
    "application/json" = <<EOF
    Action=AssumeRole&
    RoleArn=${aws_iam_role.sqs.arn}&
    Tags.member.1.Key=subject-distinguished-name&
    Tags.member.1.Value=$context.identity.clientCert.subjectDN
    EOF
  }
}

resource "aws_iam_role" "sqs" {
  name = "${var.namespace}-sqs"
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
        for client, queue_name in local.client_queues :
        {
          Action = [
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:PurgeQueue",
            "sqs:ReceiveMessage",
          ],
          Effect   = "Allow"
          Sid      = "${client}-to-sqs"
          Resource = ["arn:aws:sqs:${var.region}:${data.aws_caller_identity.current.account_id}:${queue_name}"]
          Condition = {
            StringEquals = {
              "aws:PrincipalTag/subject-distinguished-name" = client
            }
          }
        }
      ]
    })
  }
}
