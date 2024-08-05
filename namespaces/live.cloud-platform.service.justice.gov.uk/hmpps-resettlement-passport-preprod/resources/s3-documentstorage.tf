/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */
module "document_storage_s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace


  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london

  }
}


resource "kubernetes_secret" "document_storage_s3_bucket" {
  metadata {
    name      = "s3-bucket-document-storage"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.document_storage_s3_bucket.bucket_arn
    bucket_name = module.document_storage_s3_bucket.bucket_name
  }
}
