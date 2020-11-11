resource "aws_api_gateway_rest_api" "apigw" {
  name = "track-a-move"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "tracking" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  parent_id   = aws_api_gateway_rest_api.apigw.root_resource_id
  path_part   = "tracking"
}

resource "aws_api_gateway_method" "tracking_post" {
  rest_api_id   = aws_api_gateway_rest_api.apigw.id
  resource_id   = aws_api_gateway_resource.tracking.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "tracking_get_integration" {
  rest_api_id          = aws_api_gateway_rest_api.apigw.id
  resource_id          = aws_api_gateway_resource.tracking.id
  http_method          = aws_api_gateway_method.tracking_post.http_method
  type                 = "AWS"
  integration_http_method = "POST"
  uri = "arn:aws:apigateway:eu-west-2:firehose:action/PutRecordBatch"
  credentials = "arn:aws:iam::633837037006:role/APIGWTracking"

  passthrough_behavior = "WHEN_NO_TEMPLATES"

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-amx-json-1.1'"
  }

   request_templates       = {
     "application/json" = <<EOT
{
#set( $newline = "
")
"DeliveryStreamName": "${aws_kinesis_firehose_delivery_stream.extended_s3_stream.name}",
"Records": [
   #foreach($elem in $input.path('$'))
      {
        #set($record = "$elem$newline")
        "Data": "$util.base64Encode($record)"
      }#if($foreach.hasNext),#end
    #end
]
}
EOT
}

}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.tracking.id
  http_method = aws_api_gateway_method.tracking_post.http_method
  status_code = "200"
  response_models = {
    "application/json" = "Empty"
  }
}


resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.apigw.id
  resource_id = aws_api_gateway_resource.tracking.id
  http_method = aws_api_gateway_method.tracking_post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = ""
  }
}


