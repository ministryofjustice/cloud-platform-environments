module "pathfinder_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
}

# The pathfinder app needs extra permissions, in addition to the default policy in the s3 module.
data "aws_iam_policy_document" "document_s3_additional_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowBucketActions"
    effect = "Allow"
    actions = [
      "s3:PutLifecycleConfiguration"
    ]
    resources = [module.pathfinder_document_s3_bucket.bucket_arn]
  }
}

resource "aws_iam_policy" "irsa_additional_s3_policy" {
  name   = "cloud-platform-s3-${module.pathfinder_document_s3_bucket.bucket_name}"
  path   = "/cloud-platform/s3/"
  policy = data.aws_iam_policy_document.document_s3_additional_policy.json
  tags   = local.default_tags
}

module "pathfinder_rds_to_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.8.2"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business-unit          = var.business_unit
  application            = var.application
  is-production          = var.is_production
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "pathfinder_document_s3_bucket" {
  metadata {
    name      = "pathfinder-document-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.pathfinder_document_s3_bucket.bucket_arn
    bucket_name       = module.pathfinder_document_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "pathfinder_rds_to_s3_bucket" {
  metadata {
    name      = "pathfinder-rds-to-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn        = module.pathfinder_rds_to_s3_bucket.bucket_arn
    bucket_name       = module.pathfinder_rds_to_s3_bucket.bucket_name
  }
}
