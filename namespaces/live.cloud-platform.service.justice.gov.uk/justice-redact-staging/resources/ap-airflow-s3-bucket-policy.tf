# Grants Analytical Platform Airflow access to this namespace's S3 bucket via a
# resource policy trusting the workflow's IAM role directly (no static keys).
#
# Goes in: namespaces/live.cloud-platform.service.justice.gov.uk/justice-redact-staging/resources/
# Bucket:  cloud-platform-92bb1800eb01aa9300d2febcc49b929a (module.s3_bucket)
#
# This namespace also has a separate logging bucket (aws_s3_bucket.s3_logging_bucket)
# with a similar cloud-platform-<hex> name. The policy references the module's
# outputs so it can only ever attach to the primary bucket, not the logging one.

variable "ap_airflow_role_arn" {
  description = "IAM role ARN that AP Airflow uses for the staging workflow (AP environment=test, project=justice-redact, workflow=s3-sync-staging)."
  type        = string
  default     = "arn:aws:iam::593291632749:role/airflow-test-justice-redact-s3-sync-staging"
}

resource "aws_s3_bucket_policy" "ap_airflow_access" {
  bucket = module.s3_bucket.bucket_name
  policy = data.aws_iam_policy_document.ap_airflow_bucket_policy.json
}

data "aws_iam_policy_document" "ap_airflow_bucket_policy" {
  statement {
    sid    = "AllowApAirflowListAndLocate"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.ap_airflow_role_arn]
    }

    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      module.s3_bucket.bucket_arn
    ]
  }

  statement {
    sid    = "AllowApAirflowReadWriteObjects"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [var.ap_airflow_role_arn]
    }

    actions = [
      "s3:GetObject*",
      "s3:PutObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}