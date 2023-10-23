module "manage_soc_cases_document_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = true
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

# The manage-soc-cases app needs extra permissions, in addition to the default policy in the s3 module.
data "aws_iam_policy_document" "document_s3_additional_policy" {
  version = "2012-10-17"
  statement {
    sid    = "AllowBucketActions"
    effect = "Allow"
    actions = [
      "s3:PutLifecycleConfiguration"
    ]
    resources = [module.manage_soc_cases_document_s3_bucket.bucket_arn]
  }
}

resource "aws_iam_policy" "irsa_additional_s3_policy" {
  name   = "cloud-platform-s3-${module.manage_soc_cases_document_s3_bucket.bucket_name}"
  path   = "/cloud-platform/s3/"
  policy = data.aws_iam_policy_document.document_s3_additional_policy.json
  tags   = local.default_tags
}

module "manage_soc_cases_rds_to_s3_bucket" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.1.0"
  team_name              = var.team_name
  acl                    = "private"
  versioning             = false
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace
}

resource "kubernetes_secret" "manage_soc_cases_document_s3_bucket" {
  metadata {
    name      = "manage-soc-cases-document-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.manage_soc_cases_document_s3_bucket.bucket_arn
    bucket_name = module.manage_soc_cases_document_s3_bucket.bucket_name
  }
}

resource "kubernetes_secret" "manage_soc_cases_rds_to_s3_bucket" {
  metadata {
    name      = "manage-soc-cases-rds-to-s3-bucket-output"
    namespace = var.namespace
  }

  data = {
    bucket_arn  = module.manage_soc_cases_rds_to_s3_bucket.bucket_arn
    bucket_name = module.manage_soc_cases_rds_to_s3_bucket.bucket_name
  }
}
