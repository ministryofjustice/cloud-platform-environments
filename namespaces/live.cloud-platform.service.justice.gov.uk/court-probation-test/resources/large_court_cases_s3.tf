module "large-court-cases-s3-bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = "large-court-cases"
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
      id                                     = "expire-large-court-cases"
      abort_incomplete_multipart_upload_days = 90
      expiration = [
        {
          days = 30
        },
      ]
      noncurrent_version_expiration = [
        {
          days = 30
        },
      ]
    },
  ]
}

resource "kubernetes_secret" "large-court-cases-s3-secret" {
  metadata {
    name      = "large-court-cases-s3-credentials"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.large-court-cases-s3-bucket.bucket_arn
    bucket_name = module.large-court-cases-s3-bucket.bucket_name
  }
}

resource "aws_ssm_parameter" "large-court-cases-s3-bucket-name" {
  type        = "String"
  name        = "/${var.namespace}/large-court-cases-s3-bucket-name"
  value       = module.large-court-cases-s3-bucket.bucket_name
  description = "Name of Bucket used to store large court messages"

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

resource "aws_ssm_parameter" "large-court-cases-s3-bucket-arn" {
  type        = "String"
  name        = "/${var.namespace}/large-court-cases-s3-bucket-arn"
  value       = module.large-court-cases-s3-bucket.bucket_arn
  description = "ARN of Bucket used to store large court messages"

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