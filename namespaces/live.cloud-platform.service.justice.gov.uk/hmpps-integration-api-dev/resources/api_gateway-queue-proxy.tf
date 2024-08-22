locals {
  client_queues = {
    mapps.client.org = module.event_mapps_queue
    pnd   = module.event_pnd_queue
    test  = module.event_test_client_queue
  }
}

resource "aws_api_gateway_resource" "queue_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "queue"
}

resource "aws_api_gateway_method" "queue_post" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway.id
  resource_id      = aws_api_gateway_resource.queue_resource.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "sqs_proxy_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.event_proxy.id
  http_method             = aws_api_gateway_method.queue_post.http_method
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  uri                     = aws_lambda_function.sqs_routing.invoke_arn
}

data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/js"
  output_path = "${path.module}/js.zip"
}

resource "aws_lambda_function" "sqs_routing" {
  filename      = data.archive_file.zip.output_path
  function_name = "${var.namespace}-sqs-routing"
  role          = aws_iam_role.lambda_to_sqs.arn
  handler       = "index.handler"
  runtime       = "nodejs20.x"
  source_code_hash = filebase64sha256("lambda.zip")
  environment {
    variables = {
      CLIENT_QUEUES = jsonencode({ for k, v in local.client_queues : k => v.sqs_name })
    }
  }
}

resource "aws_lambda_permission" "api_gateway_to_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.sqs_routing.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${var.aws_account_id}:${aws_api_gateway_rest_api.api_gateway.id}/*/${aws_api_gateway_method.queue_post.http_method}${aws_api_gateway_resource.queue_resource.path}"
}

resource "aws_iam_role" "lambda_to_sqs" {
  name               = "${var.namespace}-sqs-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "Allow Lambda service to assume role"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
  inline_policy {
    policy = jsonencode({
      Version = "2012-10-17",
      Statement = [
        {
          Action = [
            "sqs:ChangeMessageVisibility",
            "sqs:DeleteMessage",
            "sqs:GetQueueAttributes",
            "sqs:PurgeQueue",
            "sqs:ReceiveMessage",
          ],
          Effect   = "Allow",
          Sid      = "Allow role to access messages in SQS",
          Resource = local.client_queues[*].sqs_arn
        }
      ]
    })
  }
}
