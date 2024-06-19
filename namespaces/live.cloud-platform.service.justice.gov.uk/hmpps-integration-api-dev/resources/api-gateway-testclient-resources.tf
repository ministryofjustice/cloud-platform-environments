resource "aws_api_gateway_rest_api" "api_gateway_test_client" {
  name                         = "${var.namespace}_test_client_events"
  disable_execute_api_endpoint = false

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "testclient_parent_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test_client.id
  parent_id   = aws_api_gateway_rest_api.api_gateway_test_client.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_resource" "sqs_test_client_resource" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test_client.id
  parent_id   = aws_api_gateway_resource.testclient_parent_resource.id
  path_part   = "test_client"
}
resource "aws_api_gateway_method" "sqs_test_client_method" {
  rest_api_id      = aws_api_gateway_rest_api.api_gateway_test_client.id
  resource_id      = aws_api_gateway_resource.sqs_test_client_resource.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true

  depends_on = [
    aws_api_gateway_rest_api.api_gateway_test_client,
    aws_api_gateway_resource.testclient_parent_resource,
    aws_api_gateway_resource.sqs_test_client_resource
  ]
}

resource "aws_api_gateway_method_response" "sqs_test_client_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test_client.id
  resource_id = aws_api_gateway_resource.sqs_test_client_resource.id
  http_method = aws_api_gateway_method.sqs_test_client_method.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}



resource "aws_iam_role" "api_gateway_sqs_test_client_role" {
  name               = "${var.namespace}-api-gateway-sqs-test-client-role"
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


resource "aws_iam_role_policy" "api_gateway_sqs_test_client_policy" {
  name = "${var.namespace}-api-gateway-sqs-test-client-policy"
  role = aws_iam_role.api_gateway_sqs_test_client_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "sqs:ReceiveMessage"
        Resource = module.event_test_client_queue.sqs_arn
      }
    ]
  })
  depends_on = [
    aws_iam_role.api_gateway_sqs_test_client_role,
    module.event_test_client_queue
  ]
}

resource "aws_api_gateway_integration" "sqs_test_client_integration" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway_test_client.id
  resource_id             = aws_api_gateway_resource.sqs_test_client_resource.id
  http_method             = aws_api_gateway_method.sqs_test_client_method.http_method
  type                    = "AWS"
  integration_http_method = "GET"
  uri                     = "arn:aws:apigateway:${var.region}:sqs:path/${data.aws_caller_identity.current.account_id}/${module.event_test_client_queue.sqs_name}?Action=ReceiveMessage"

  depends_on = [
    aws_api_gateway_rest_api.api_gateway_test_client,
    aws_api_gateway_resource.sqs_test_client_resource,
    module.event_test_client_queue,
    aws_api_gateway_method.sqs_test_client_method,
    aws_api_gateway_method_response.sqs_test_client_method_response,
  ]

  credentials = aws_iam_role.api_gateway_sqs_test_client_role.arn
}

resource "aws_api_gateway_integration_response" "sqs_test_client_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test_client.id
  resource_id = aws_api_gateway_resource.sqs_test_client_resource.id
  http_method = aws_api_gateway_method.sqs_test_client_method.http_method
  status_code = aws_api_gateway_method_response.sqs_test_client_method_response.status_code

  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_rest_api.api_gateway_test_client,
    aws_api_gateway_integration.sqs_test_client_integration
  ]
}

resource "aws_api_gateway_deployment" "test-client-deployment" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway_test_client.id

  triggers = {
    redeployment = sha1(jsonencode([
      # "manual-deploy-trigger",
      local.clients,
      var.cloud_platform_integration_api_url,
      md5(file("api-gateway-testclient-resources.tf"))
    ]))
  }

  depends_on = [
    aws_api_gateway_method.sqs_test_client_method,   
    aws_api_gateway_integration.sqs_test_client_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "test-client-event" {
  deployment_id         = aws_api_gateway_deployment.test-client-deployment.id
  rest_api_id           = aws_api_gateway_rest_api.api_gateway_test_client.id
  stage_name            = var.namespace
  client_certificate_id = aws_api_gateway_client_certificate.api_gateway_client_two.id

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway_access_logs.arn
    format = jsonencode({
      extendedRequestId  = "$context.extendedRequestId"
      ip                 = "$context.identity.sourceIp"
      client             = "$context.identity.clientCert.subjectDN"
      issuerDN           = "$context.identity.clientCert.issuerDN"
      requestTime        = "$context.requestTime"
      httpMethod         = "$context.httpMethod"
      resourcePath       = "$context.resourcePath"
      status             = "$context.status"
      responseLength     = "$context.responseLength"
      error              = "$context.error.message"
      authenticateStatus = "$context.authenticate.status"
      authenticateError  = "$context.authenticate.error"
      integrationStatus  = "$context.integration.status"
      integrationError   = "$context.integration.error"
      apiKeyId           = "$context.identity.apiKeyId"
    })
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_cloudwatch_log_group.api_gateway_access_logs]
}
resource "aws_api_gateway_usage_plan" "test_client_events" {
  name = "${var.namespace}-events"

  api_stages {
    api_id = aws_api_gateway_rest_api.api_gateway_test_client.id
    stage  = aws_api_gateway_stage.test-client-event.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "test_client_events_client" {

  key_id        = aws_api_gateway_api_key.clients["event-service"].id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.test_client_events.id

   depends_on = [
    aws_api_gateway_api_key.clients
  ]

}

resource "aws_api_gateway_base_path_mapping" "testclient-event-hostname" {
  for_each = aws_api_gateway_domain_name.api_gateway_fqdn

  api_id      = aws_api_gateway_rest_api.api_gateway_test_client.id
  domain_name = aws_api_gateway_domain_name.api_gateway_fqdn[each.key].domain_name
  stage_name  = aws_api_gateway_stage.test-client-event.stage_name
}

