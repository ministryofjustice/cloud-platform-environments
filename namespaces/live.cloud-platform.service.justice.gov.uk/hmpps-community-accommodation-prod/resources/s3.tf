module "s3_bucket" {

  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.1"
  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }

  lifecycle_rule = [
    {
      enabled                                = true
      id                                     = "expire-files-after-90-days"
      abort_incomplete_multipart_upload_days = 90
      expiration = [
        {
          days = 90
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 90
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

resource "aws_ssm_parameter" "s3_bucket_name" {
  type        = "String"
  name        = "/${var.namespace}/s3-bucket-name"
  value       = module.s3_bucket.bucket_name
  description = "Name of the S3 bucket used for HMPPS Community Accommodation"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_ssm_parameter" "s3_bucket_arn" {
  type        = "String"
  name        = "/${var.namespace}/s3-bucket-arn"
  value       = module.s3_bucket.bucket_arn
  description = "ARN of the S3 bucket used for HMPPS Community Accommodation"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "aws_ssm_parameter" "s3_bucket_policy" {
  type        = "String"
  name        = "/${var.namespace}/s3-bucket-policy"
  value       = module.s3_bucket.irsa_policy_arn
  description = "IRSA policy ARN of the S3 bucket used for HMPPS Community Accommodation"

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

