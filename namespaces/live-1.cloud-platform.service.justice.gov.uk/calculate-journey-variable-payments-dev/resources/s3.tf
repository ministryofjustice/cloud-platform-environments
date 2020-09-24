/*
 Based on https://github.com/ministryofjustice/cloud-platform-terraform-s3-bucket/tree/main/example
 */
module "calculate_journey_payments_s3_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=4.4"

  team_name              = var.team_name
  business-unit          = var.business-unit
  application            = var.application
  infrastructure-support = var.infrastructure-support

  is-production    = var.is-production
  environment-name = var.environment-name

  providers = {
    # Can be either "aws.london" or "aws.ireland"
    aws = aws.london
  }

  versioning    = false
  bucket_policy = data.aws_iam_policy_document.policy.json

}

data "aws_iam_policy_document" "policy" {
  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]

    resources = [
      "$${bucket_arn}"
    ]
  }

  statement {
    actions = [
      "s3:AbortMultipartUpload",
      "s3:DeleteObject",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectVersionTagging",
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectTorrent",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
      "s3:GetObjectVersionTorrent",
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:PutObjectTagging",
      "s3:PutObjectVersionAcl",
      "s3:PutObjectVersionTagging",
      "s3:RestoreObject",
    ]

    resources = [
      "$${bucket_arn}/*"
    ]
  }

  statement {
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]

    resources = [
      "arn:aws:s3:::cloud-platform-0ca42ca2f8c46427f4fe217398336ab5"
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:GetObjectTagging",
      "s3:GetObjectVersion",
      "s3:GetObjectVersionAcl",
      "s3:GetObjectVersionTagging",
    ]

    resources = [
      "arn:aws:s3:::cloud-platform-0ca42ca2f8c46427f4fe217398336ab5/*"
    ]
  }



}

resource "kubernetes_secret" "calculate_journey_payments_s3_bucket" {
  metadata {
    name      = "calculate-journey-payments-s3"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.calculate_journey_payments_s3_bucket.access_key_id
    secret_access_key = module.calculate_journey_payments_s3_bucket.secret_access_key
    bucket_arn        = module.calculate_journey_payments_s3_bucket.bucket_arn
    bucket_name       = module.calculate_journey_payments_s3_bucket.bucket_name
  }
}
