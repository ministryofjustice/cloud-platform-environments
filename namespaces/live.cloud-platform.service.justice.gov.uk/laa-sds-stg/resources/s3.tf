/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "laa_sds_equiniti" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
  bucket_name            = "laa-sds-equiniti-${var.environment}"
}


resource "kubernetes_secret" "equiniti_s3" {
  metadata {
    name      = "laa-sds-s3-equiniti-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.laa_sds_equiniti.bucket_arn
    bucket_name = module.laa_sds_equiniti.bucket_name
  }
}



