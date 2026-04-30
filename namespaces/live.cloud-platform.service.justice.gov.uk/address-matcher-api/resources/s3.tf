module "address_matcher_models_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  versioning             = true
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = { aws = aws.london }
}

module "address_matcher_lookup_data_s3" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  versioning             = true
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = { aws = aws.london }
}

resource "kubernetes_secret" "s3_buckets" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    models_bucket_arn       = module.address_matcher_models_s3.bucket_arn
    models_bucket_name      = module.address_matcher_models_s3.bucket_name
    lookup_data_bucket_arn  = module.address_matcher_lookup_data_s3.bucket_arn
    lookup_data_bucket_name = module.address_matcher_lookup_data_s3.bucket_name
  }
}
