
module "sw_test_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  logging_enabled        = true
  log_target_bucket      = module.sw_test_logging_bucket.bucket_name
  log_path               = "test/"
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "sw_test_logging_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0"
  team_name              = var.team_name
  acl                    = "log-delivery-write"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "sw_test_bucket" {
  metadata {
    name      = "test-s3-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.sw_test_bucket.bucket_arn
    bucket_name = module.sw_test_logging_bucket.bucket_name
  }
}

resource "kubernetes_secret" "sw_test_logging_bucket" {
  metadata {
    name      = "test-s3-logging-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.sw_test_logging_bucket.bucket_arn
    bucket_name = module.sw_test_logging_bucket.bucket_name
  }
}