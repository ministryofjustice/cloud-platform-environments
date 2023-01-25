module "truststore_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.7.3"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
  versioning             = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "truststore_s3_bucket" {
  metadata {
    name      = "truststore-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.truststore_s3_bucket.access_key_id
    secret_access_key = module.truststore_s3_bucket.secret_access_key
    bucket_arn        = module.truststore_s3_bucket.bucket_arn
    bucket_name       = module.truststore_s3_bucket.bucket_name
  }
}

resource "aws_s3_object" "truststore" {
  bucket = module.truststore_s3_bucket.bucket_name
  key    = "truststore.pem"
  source = "truststore.pem"

  etag = filemd5("./truststore.pem")
}
