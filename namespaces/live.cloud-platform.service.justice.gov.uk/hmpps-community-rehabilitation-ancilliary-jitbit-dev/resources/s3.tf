/*
 * Make sure that you use the latest version of the module by changing the
 * `ref=` value in the `source` attribute to the latest version listed on the
 * releases page of this repository.
 *
 */

##
#  Create bucket and secret for jitbit app files
##
module "s3_bucket" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.0.0"
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace
  enable_allow_block_pub_access = true
  acl                           = "private"
  versioning                    = false
  logging_enabled               = false
  lifecycle_rule                = []
  cors_rule                     = []

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london

  }
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-jitbit-app-files-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

##
#  Create bucket and secret for jitbit app artefacts - used by the docker build process
##
module "s3_bucket_jitbit_app_artefacts" {
  source                        = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.0.0"
  team_name                     = var.team_name
  business_unit                 = var.business_unit
  application                   = var.application
  is_production                 = var.is_production
  environment_name              = var.environment
  infrastructure_support        = var.infrastructure_support
  namespace                     = var.namespace
  enable_allow_block_pub_access = true
  acl                           = "private"
  versioning                    = false
  logging_enabled               = false
  lifecycle_rule                = []
  cors_rule                     = []

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london

  }
}

resource "kubernetes_secret" "s3_bucket_jitbit_app_artefacts" {
  metadata {
    name      = "s3-bucket-jitbit-app-artefacts-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket_jitbit_app_artefacts.bucket_arn
    bucket_name = module.s3_bucket_jitbit_app_artefacts.bucket_name
  }
}
