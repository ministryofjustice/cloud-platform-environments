resource "kubernetes_secret" "aws_services" {
  metadata {
    name      = "aws-services"
    namespace = var.namespace
  }

  data = {
    "ecr" = jsonencode({
      "access-credentials" = {
        "access-key-id"     = module.ecr_credentials.access_key_id
        "secret-access-key" = module.ecr_credentials.secret_access_key
      }
      "repo-arn"         = module.ecr_credentials.repo_arn
      "repo-url"          = module.ecr_credentials.repo_url
    })

    "s3" = jsonencode({
      "access-credentials" = {
        "access-key-id"     = module.truststore_s3_bucket.access_key_id
        "secret-access-key" = module.truststore_s3_bucket.secret_access_key
      }
      "bucket-arn"        = module.truststore_s3_bucket.bucket_arn
      "bucket-name"       = module.truststore_s3_bucket.bucket_name
    })
  }
}



