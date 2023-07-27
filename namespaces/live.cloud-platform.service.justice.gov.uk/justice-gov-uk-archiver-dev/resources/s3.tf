module "s3" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
  providers = {
    aws = aws.london
  }
}

resource "aws_s3_bucket_website_configuration" "s3" {
  bucket = module.s3.bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

resource "kubernetes_secret" "s3" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.s3.access_key_id
    secret_access_key = module.s3.secret_access_key
    bucket_arn        = module.s3.bucket_arn
    bucket_name       = module.s3.bucket_name
  }
}
