terraform {
  backend "s3" {
  }
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "london"
  region = "eu-west-2"
}

provider "aws" {
  alias  = "ireland"
  region = "eu-west-1"
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

data "aws_iam_policy_document" "irsa_laa_test_viewer" {
  version = "2012-10-17"
  statement {
    sid    = "AllowBucketActions"
    effect = "Allow"
    actions = [
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:ListBucketVersions",
    ]
    resources = "${module.s3_bucket.bucket_arn}/*"
  }


  statement {
    sid    = "AllowObjectActions"
    effect = "Allow"
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
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}