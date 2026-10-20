# Getting the justice-redact Staging RDS database onto the Analytical Platform.
# Pattern: https://user-guide.cloud-platform.service.justice.gov.uk/documentation/other-topics/getting-your-data-onto-the-analytical-platform.html[cite: 1]

resource "random_id" "ap_rds_export_id_staging" {
  byte_length = 16
}

resource "aws_iam_user" "ap_rds_export_user_staging" {
  name = "ap-s3-bucket-user-${random_id.ap_rds_export_id_staging.hex}"
  path = "/system/ap-s3-bucket-user/"
}

resource "aws_iam_access_key" "ap_rds_export_user_staging" {
  user = aws_iam_user.ap_rds_export_user_staging.name
}

resource "aws_iam_user_policy" "ap_rds_export_policy_staging" {
  name   = "${var.namespace}-ap-s3-snapshots"
  policy = data.aws_iam_policy_document.ap_rds_export_access_staging.json
  user   = aws_iam_user.ap_rds_export_user_staging.name
}

data "aws_iam_policy_document" "ap_rds_export_access_staging" {
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
      # NOTE: Adjust the bucket / prefix if your staging landing bucket path differs
      "arn:aws:s3:::moj-reg-dev-curated/justice-redact-staging/*",
      "arn:aws:s3:::moj-reg-dev-curated/justice-redact-staging/"
    ]
  }
}

resource "kubernetes_secret" "ap_aws_secret_staging" {
  metadata {
    name      = "analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://moj-reg-dev-curated/justice-redact-staging/"
    user_arn            = aws_iam_user.ap_rds_export_user_staging.arn
    access_key_id       = aws_iam_access_key.ap_rds_export_user_staging.id
    secret_access_key   = aws_iam_access_key.ap_rds_export_user_staging.secret
  }
}