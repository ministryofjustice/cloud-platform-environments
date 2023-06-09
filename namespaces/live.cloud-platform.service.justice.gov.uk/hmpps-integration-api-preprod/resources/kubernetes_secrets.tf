resource "kubernetes_secret" "aws_services" {
  metadata {
    name      = "aws-services"
    namespace = var.namespace
  }

  data = {
    "api-gateway" = jsonencode({
      "cloudwatch-log-url" = "https://eu-west-2.console.aws.amazon.com/cloudwatch/home?region=eu-west-2#logsV2:log-groups/log-group/${aws_cloudwatch_log_group.api_gateway_access_logs.name}"
      "access-credentials" = {
        "access-key-id"     = aws_iam_access_key.api_gateway_user.id
        "secret-access-key" = aws_iam_access_key.api_gateway_user.secret
      }
    })

    "ecr" = jsonencode({
      "access-credentials" = {
        "access-key-id"     = module.ecr_credentials.access_key_id
        "secret-access-key" = module.ecr_credentials.secret_access_key
      }
      "repo-arn" = module.ecr_credentials.repo_arn
      "repo-url" = module.ecr_credentials.repo_url
    })

    "s3" = jsonencode({
      "access-credentials" = {
        "access-key-id"     = module.truststore_s3_bucket.access_key_id
        "secret-access-key" = module.truststore_s3_bucket.secret_access_key
      }
      "bucket-arn"  = module.truststore_s3_bucket.bucket_arn
      "bucket-name" = module.truststore_s3_bucket.bucket_name
    })
  }

  depends_on = [
    aws_cloudwatch_log_group.api_gateway_access_logs,
    aws_api_gateway_api_key.clients
  ]
}

resource "kubernetes_secret" "client_certificate_auth" {
  metadata {
    name      = "client-certificate-auth"
    namespace = var.namespace
  }

  data = {
    "ca.crt" = aws_api_gateway_client_certificate.api_gateway_client.pem_encoded_certificate
  }
}

resource "kubernetes_secret" "consumer_api_keys" {
  metadata {
    name      = "consumer-api-keys"
    namespace = var.namespace
  }

  data = {
    for client in local.clients : client => aws_api_gateway_api_key.clients[client].value
  }
}



