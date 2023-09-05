# auto-generated from fb-cloud-platforms-environments
##################################################
# User Filestore S3
module "user-filestore-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.9.0"

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-28d"
      prefix                                 = "28d/"
      abort_incomplete_multipart_upload_days = 28
      expiration = [
        {
          days = 28
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 28
        },
      ]
    },
  ]
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # IRSA configuration
  service_account_name = "user-filestore-irsa-${var.environment-name}"
  namespace            = var.namespace # this is also used as a tag

  role_policy_arns = {
    s3  = module.s3.irsa_policy_arn
  }

  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = "transformed-department"
  application            = "formbuilderuserfilestore"
  is_production          = var.is_production
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "user-filestore-s3-bucket" {
  metadata {
    name      = "s3-formbuilder-user-filestore-${var.environment-name}"
    namespace = "formbuilder-platform-${var.environment-name}"
  }

  data = {
    access_key_id     = module.user-filestore-s3-bucket.access_key_id
    bucket_arn        = module.user-filestore-s3-bucket.bucket_arn
    bucket_name       = module.user-filestore-s3-bucket.bucket_name
    secret_access_key = module.user-filestore-s3-bucket.secret_access_key
  }
}
