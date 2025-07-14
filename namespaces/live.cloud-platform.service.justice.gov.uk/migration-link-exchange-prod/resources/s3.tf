# This S3 bucket is used to store the following:
# - The input data for the `migration-link-exchange-build` namespace/service.
# - The output data of the `migration-link-exchange-build` namespace/service.
# The bucket has been created in *this* namespace so that:
# - The bucket can can be accessed by this service.
# - The data will persist even after the `migration-link-exchange-build` namespace is deleted.

module "s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"
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
}

# Save the bucket ARN and name to a Kubernetes secret
# So that is can be access by deployments in this namespace.

resource "kubernetes_secret" "s3_bucket" {
  metadata {
    name      = "s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.s3_bucket.bucket_arn
    bucket_name = module.s3_bucket.bucket_name
  }
}

# Save the bucket ARN and name to SSM parameters, so that they can be 
# accessed in the `migration-link-exchange-build` namespace.
# Lifecycle: these `aws_ssm_parameter` blocks should be removed when the 
# `migration-link-exchange-build` namespace is deleted.
# Ref: 
# https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/sharing-aws-resources-across-namespaces-using-ssm-and-irsa.html

resource "aws_ssm_parameter" "s3-bucket-name" {
    type        = "String"
    name        = "/${var.namespace}/s3-bucket-name"
    # specify the module of an existing resource here
    value       = module.s3_bucket.bucket_name
    description = "Name of Bucket to be accessed from namespace migration-link-exchange-build-prod"
    tags = {
        business-unit          = var.business_unit
        application            = var.application
        is-production          = var.is_production
        owner                  = var.team_name
        environment_name       = var.environment
        infrastructure-support = var.infrastructure_support
        namespace              = var.namespace
    }
}

resource "aws_ssm_parameter" "s3-bucket-arn" {
    type        = "String"
    name        = "/${var.namespace}/s3-bucket-arn"
    # specify the module of an existing resource here
    value       = module.s3_bucket.bucket_arn
    description = "ARN of Bucket to be accessed from migration-link-exchange-build-prod"
    tags = {
      business-unit          = var.business_unit
      application            = var.application
      is_production          = var.is_production
      team_name              = var.team_name
      environment            = var.environment
      infrastructure-support = var.infrastructure_support
      namespace              = var.namespace
    }
}
