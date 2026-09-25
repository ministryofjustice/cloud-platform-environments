# Getting the justice-redact RDS database onto the Analytical Platform.
# Pattern: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/getting-your-data-onto-the-analytical-platform.html
#
# This is step 1 of 3: create the IAM user the Data Extractor cronjob (running
# inside this namespace) will use to write the daily DB dump to the
# Register My Data "landing" bucket. Steps 2 (deploy the extractor) and 3
# (register the ETL pipeline) happen outside this file — see notes below.
#
# Bucket path convention: moj-reg-<env>/landing/<service>-<env>/*
# service = justice-redact, env = dev

resource "random_id" "ap_rds_export_id" {
  byte_length = 16
}

resource "aws_iam_user" "ap_rds_export_user" {
  name = "ap-s3-bucket-user-${random_id.ap_rds_export_id.hex}"
  path = "/system/ap-s3-bucket-user/"
}

resource "aws_iam_access_key" "ap_rds_export_user" {
  user = aws_iam_user.ap_rds_export_user.name
}

resource "aws_iam_user_policy" "ap_rds_export_policy" {
  name   = "${var.namespace}-ap-s3-snapshots"
  policy = data.aws_iam_policy_document.ap_rds_export_access.json
  user   = aws_iam_user.ap_rds_export_user.name
}

data "aws_iam_policy_document" "ap_rds_export_access" {
  statement {
    sid = "AllowRdsExportUserToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]
    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowRdsExportUserWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]
    resources = [
      "arn:aws:s3:::moj-reg-dev/landing/justice-redact-dev/*",
      "arn:aws:s3:::moj-reg-dev/landing/justice-redact-dev/"
    ]
  }
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://moj-reg-dev/landing/justice-redact-dev/"
    user_arn            = aws_iam_user.ap_rds_export_user.arn
    access_key_id       = aws_iam_access_key.ap_rds_export_user.id
    secret_access_key   = aws_iam_access_key.ap_rds_export_user.secret
  }
}