# Generate an additional IAM user to manage APIGW
resource "random_id" "apigw-id" {
  byte_length = 16
}

resource "aws_iam_user" "apigw-user" {
  name = "apigw-user-${random_id.apigw-id.hex}"
  path = "/system/apigw-user/"
}

resource "aws_iam_access_key" "apigw-user" {
  user = aws_iam_user.apigw-user.name
}

data "aws_iam_policy_document" "apigw" {
  statement {
    actions = [
      "apigateway:*",
    ]
    resources = [
      "${aws_api_gateway_rest_api.api_gateway.arn}/*",
      aws_api_gateway_rest_api.api_gateway.arn
    ]
    effect = "Allow"
  }

  statement {
    actions = [
      "apigateway:*",
    ]
    resources = [
      "arn:aws:apigateway:eu-west-2::/restapis"
    ]
    effect = "Allow"
  }
}

resource "aws_iam_user_policy" "apigw-policy" {
  name   = "${var.namespace}-apigw"
  policy = data.aws_iam_policy_document.apigw.json
  user   = aws_iam_user.apigw-user.name
}

resource "aws_iam_role" "api_gateway_role" {
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

# resource "aws_iam_role_policy" "api_gw_s3" {
#   name = "${var.namespace}-apigw-s3"
#   role = aws_iam_role.api_gateway_role.name

#   policy = <<EOF
# {
#   "Version" : "2012-10-17",
#   "Statement" : [
#     {
#       "Sid": "AllowPutObject",
#       "Effect": "Allow",
#       "Action": "s3:PutObject",

#       "Resource": [
#         "${module.s3_bucket.bucket_arn}/*",
#         "${module.s3_bucket.bucket_arn}"
#       ]
#     }
#   ]
# }
# EOF
# }

resource "kubernetes_secret" "iac_fees_apigw_iam" {
  metadata {
    name      = "apigateway-iam"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.apigw-user.id
    secret_access_key = aws_iam_access_key.apigw-user.secret
    invoke_url        = aws_api_gateway_deployment.main.invoke_url
  }
}
