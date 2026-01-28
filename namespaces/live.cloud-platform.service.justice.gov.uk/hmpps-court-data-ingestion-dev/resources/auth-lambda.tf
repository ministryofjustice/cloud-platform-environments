resource "aws_iam_role" "lambda_role" {
  name = "authorizer-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_lambda_function" "authorizer" {
  function_name = "hmac-authorizer"
  runtime       = "nodejs18.x"
  handler       = "authorizer.handler"
  role          = aws_iam_role.lambda_role.arn
  filename      = "dummy.zip"


#TODO get secret from ssm.
  environment {
    variables = {
      HMAC_SECRET = "super-secret-key"
    }
  }
}

resource "aws_lambda_permission" "authorizer" {
  statement_id  = "AllowApiGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.authorizer.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ingestion_api.execution_arn}/*/*"
}