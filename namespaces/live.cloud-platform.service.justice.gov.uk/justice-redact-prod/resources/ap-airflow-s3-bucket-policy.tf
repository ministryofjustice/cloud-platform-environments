# Grants Analytical Platform Airflow access to this bucket via a resource
# policy trusting AP Airflow's IAM role directly — no IAM user, no access
# keys to rotate. Requires confirming the exact role ARN with the
# Analytical Platform team (#ask-analytical-platform) first.

variable "ap_airflow_role_arn" {
  description = "IAM role ARN that Analytical Platform Airflow assumes for this pipeline (environment=development, project=justice-redact, workflow=s3-sync)."
  type        = string
  default     = "arn:aws:iam::593291632749:role/airflow-production-justice-redact-s3-sync-prod"
}

resource "aws_s3_bucket_policy" "ap_airflow_access" {
  bucket = "cloud-platform-95e0bb4ef4e2df0d7fbcc6f754b631a9"
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
      "arn:aws:s3:::cloud-platform-95e0bb4ef4e2df0d7fbcc6f754b631a9"
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
      "arn:aws:s3:::cloud-platform-95e0bb4ef4e2df0d7fbcc6f754b631a9/*"
    ]
  }
}