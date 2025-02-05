module "s3-distinguishing-mark-images" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.2.0" # use the latest release

  # S3 configuration

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  bucket_policy = data.aws_iam_policy_document.s3_read_write_access_policy.json
}

locals {
  document_api_service_account_arn = "arn:aws:iam::754256621582:role/cloud-platform-irsa-7660dac753043357-live"
}

# Create policy document to allow read/write access to the document API service account.
data "aws_iam_policy_document" "s3_read_write_access_policy" {
  statement {
    sid = "BucketLevelPermisions"
    principals {
      type        = "AWS"
      identifiers = [local.document_api_service_account_arn]
    }
    actions = [
      "s3:ListBucket",
    ]

    resources = ["$${bucket_arn}"]
  }

  statement {
    sid = "ReadWriteObjectPermissions"
    principals {
      type        = "AWS"
      identifiers = [local.document_api_service_account_arn]
    }
    actions = [
      "s3:PutObject",
      "s3:GetObject",
    ]
    resources = ["$${bucket_arn}/*"]
  }
}

resource "kubernetes_secret" "s3-distinguishing-mark-images" {
  metadata {
    name      = "s3-distinguishing-mark-images-output"
    namespace = var.namespace
  }
  data = {
    images_bucket_arn  = module.s3-distinguishing-mark-images.bucket_arn
    images_bucket_name = module.s3-distinguishing-mark-images.bucket_name
  }
}

resource "kubernetes_secret" "s3-distinguishing-mark-images-s3-injected" {
  metadata {
    name      = "s3-distinguishing-mark-images-output-injected"
    namespace = "hmpps-document-management-preprod"
  }
  data = {
    images_bucket_arn  = module.s3-distinguishing-mark-images.bucket_arn
    images_bucket_name = module.s3-distinguishing-mark-images.bucket_name
  }
}
