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
  document_api_service_account_arn = "arn:aws:iam::754256621582:role/cloud-platform-irsa-c2bb1b0743e08206-live"

  # List of namespaces to inject S3 outputs into.
  s3-distinguishing-mark-image-consumers = [
    var.namespace,
    "hmpps-document-management-dev"
  ]
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
  for_each = toset(local.s3-distinguishing-mark-image-consumers)
  metadata {
    name      = "s3-distinguishing-mark-images-output"
    namespace = each.key
  }

  data = {
    images_bucket_arn  = module.s3-distinguishing-mark-images.bucket_arn
    images_bucket_name = module.s3-distinguishing-mark-images.bucket_name
  }
}
