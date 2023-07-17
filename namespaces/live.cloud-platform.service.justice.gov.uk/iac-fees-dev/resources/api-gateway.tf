resource "aws_api_gateway_rest_api" "api_gateway" {
  name                         = var.namespace
  disable_execute_api_endpoint = false
  binary_media_types           = ["*/*"]

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_api_gateway_rest_api_policy" "api_policy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "execute-api:Invoke",
        "Resource": "arn:aws:execute-api:eu-west-2:754256621582:gp3sc513hg/*/*/*"
      },
      {
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:PutObject",
      "Resource": [
        "${module.s3_bucket.bucket_arn}/*",
        "${module.s3_bucket.bucket_arn}"
      ]
    }
    ]
  }
  EOF
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_rest_api.api_gateway.root_resource_id
  path_part   = "{bucket}"
}

resource "aws_api_gateway_resource" "upload_type" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.proxy.id
  path_part   = "{upload_type}"
}

resource "aws_api_gateway_resource" "filetype" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.upload_type.id
  path_part   = "{filetype}"
}

resource "aws_api_gateway_resource" "filename" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  parent_id   = aws_api_gateway_resource.filetype.id
  path_part   = "{filename}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  resource_id   = aws_api_gateway_resource.filename.id
  http_method   = "PUT"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.bucket"      = true
    "method.request.path.upload_type" = true
    "method.request.path.filetype"    = true
    "method.request.path.filename"    = true
  }
}

resource "aws_api_gateway_integration" "proxy_http_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.api_gateway.id
  resource_id             = aws_api_gateway_resource.filename.id
  http_method             = aws_api_gateway_method.proxy.http_method
  type                    = "AWS"
  integration_http_method = "PUT"
  uri                     = "arn:aws:apigateway:eu-west-2:s3:action/PutObject/cloud-platform-d3ad47215cc1ffea9eff85a1aa2575b6/*/*/*"

  credentials = aws_iam_role.api_gateway_role.arn

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "api_method_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "api_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  resource_id = aws_api_gateway_resource.filename.id
  http_method = aws_api_gateway_method.proxy.http_method
  status_code = aws_api_gateway_method_response.api_method_response.status_code
  response_templates = {
    "application/json" = ""
  }
  depends_on = [
    aws_api_gateway_integration.proxy_http_proxy
  ]
}

resource "aws_api_gateway_deployment" "main" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id

  #hack to force recreate of the deployment resource
  stage_description = md5(file("api-gateway.tf"))

  depends_on = [
    aws_api_gateway_method.proxy,
    aws_api_gateway_integration.proxy_http_proxy
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "live" {
  deployment_id = aws_api_gateway_deployment.main.id
  rest_api_id   = aws_api_gateway_rest_api.api_gateway.id
  stage_name    = "upload"
}

resource "aws_api_gateway_method_settings" "all" {
  rest_api_id = aws_api_gateway_rest_api.api_gateway.id
  stage_name  = aws_api_gateway_stage.live.stage_name
  method_path = "*/*"
  settings {
    metrics_enabled        = true
    logging_level          = "INFO"
    throttling_burst_limit = 5000
    throttling_rate_limit  = 10000
    data_trace_enabled     = false
  }
}
