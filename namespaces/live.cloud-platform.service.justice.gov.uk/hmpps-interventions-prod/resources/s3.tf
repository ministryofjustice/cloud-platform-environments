/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/main/example
 */
module "interventions_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.9.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  infrastructure_support = var.infrastructure_support

  is_production    = var.is_production
  environment_name = var.environment
  namespace        = var.namespace

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }
}

resource "kubernetes_secret" "interventions_s3_bucket" {
  metadata {
    name      = "storage-s3-bucket"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.interventions_s3_bucket.access_key_id
    secret_access_key = module.interventions_s3_bucket.secret_access_key
    bucket_arn        = module.interventions_s3_bucket.bucket_arn
    bucket_name       = module.interventions_s3_bucket.bucket_name
  }
}
