module "s3_opa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  bucket_name            = "laa-data-user-api-dev-opa-policies"
  versioning             = true

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "s3_opa" {
  metadata {
    name      = "s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_name = module.s3_opa.bucket_name
    bucket_arn  = module.s3_opa.bucket_arn
  }
}

