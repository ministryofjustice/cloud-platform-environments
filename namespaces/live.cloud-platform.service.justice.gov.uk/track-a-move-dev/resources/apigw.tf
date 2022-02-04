resource "aws_api_gateway_rest_api" "apigw" {
  name = var.namespace

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment_name
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_iam_role" "apigw_role" {
  name               = "${var.namespace}-apigw"
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

resource "aws_iam_role_policy" "api_gw_firehose_policy" {

  count = length(aws_kinesis_firehose_delivery_stream.extended_s3_stream.*.arn)
  name  = "apigw-firehose-${count.index}"

  role = aws_iam_role.apigw_role.name

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement" : [
    {
      "Effect": "Allow",
      "Action": "firehose:PutRecordBatch",

      "Resource": [
        "${element(aws_kinesis_firehose_delivery_stream.extended_s3_stream.*.arn, count.index)}"
      ]
    }
  ]
}
EOF
}


# /tracks
resource "aws_api_gateway_resource" "tracks" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "tracks"
}

# /tracks POST
resource "aws_api_gateway_method" "tracks_post" {
  rest_api_id      = aws_api_gateway_rest_api.apigw.id
  resource_id      = aws_api_gateway_resource.tracks.id
  http_method      = "POST"
  authorization    = "NONE"
  api_key_required = true
}


data "http" "template" {
  url = "https://raw.githubusercontent.com/ministryofjustice/hmpps-track-a-move/dev/mapping.vtl"
}

# /tracks POST -> firehose
resource "aws_api_gateway_integration" "tracks_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.apigw.id
  resource_id             = aws_api_gateway_resource.tracks.id
  http_method             = aws_api_gateway_method.tracks_post.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:eu-west-2:firehose:action/PutRecordBatch"
  credentials             = aws_iam_role.apigw_role.arn

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amx-json-1.1'"
  }

  request_templates = {
    "application/json" = data.http.template.body
  }

}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.tracks.id
  http_method = aws_api_gateway_method.tracks_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "tracks_post_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.tracks.id
  http_method = aws_api_gateway_method.tracks_post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }

  depends_on = [
    aws_api_gateway_integration.tracks_post_integration
  ]
}

#deployment
resource "aws_api_gateway_deployment" "live" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  stage_name  = "live"

  #hack to force recreate of the deployment resource
  stage_description = md5(file("apigw.tf"))

  depends_on = [
    aws_api_gateway_method.tracks_post,
    aws_api_gateway_integration.tracks_post_integration
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "kubernetes_secret" "apigw_details" {
  metadata {
    name      = "apigw"
    namespace = var.namespace
  }

  data = {
    invoke_url = aws_api_gateway_deployment.live.invoke_url
  }
}


#Usage plan
resource "random_id" "key" {
  count       = length(local.suppliers)
  byte_length = 16
}
resource "aws_api_gateway_api_key" "api_keys" {
  count = length(local.suppliers)
  name  = "${local.suppliers[count.index]}${var.environment_suffix}-key"
  value = "${local.suppliers[count.index]}${var.environment_suffix}-${random_id.key.*.hex[count.index]}"
}

resource "kubernetes_secret" "apikeys" {
  count = length(local.suppliers)

  metadata {
    name      = "apikey-${local.suppliers[count.index]}"
    namespace = var.namespace
  }

  data = {
    local.suppliers[count.index] = aws_api_gateway_api_key.api_keys.*.value[count.index]
  }
}

resource "aws_api_gateway_usage_plan" "default" {
  name = "track-a-move-dev"

  api_stages {
    api_id = aws_api_gateway_rest_api.apigw.id
    stage  = aws_api_gateway_deployment.live.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "main" {
  count = length(local.suppliers)

  key_id        = aws_api_gateway_api_key.api_keys.*.id[count.index]
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.default.id
}

resource "aws_api_gateway_domain_name" "apigw_fqdn" {
  domain_name              = aws_acm_certificate.apigw_custom_hostname.domain_name
  regional_certificate_arn = aws_acm_certificate_validation.apigw_custom_hostname.certificate_arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  depends_on = [aws_acm_certificate_validation.apigw_custom_hostname]
}

resource "aws_api_gateway_base_path_mapping" "mapping" {
  api_id      = aws_api_gateway_rest_api.apigw.id
  stage_name  = aws_api_gateway_deployment.live.stage_name
  domain_name = aws_api_gateway_domain_name.apigw_fqdn.domain_name
}
