
data "aws_ssm_parameter" "court_hearings_large_messages_bucket_name" {
  name = "/hmpps-person-record-${var.environment_name}/large-court-cases-s3-bucket-name"
}

data "aws_ssm_parameter" "court_hearings_large_messages_bucket_arn" {
  name = "/hmpps-person-record-${var.environment_name}/large-court-cases-s3-bucket-arn"
}

data "aws_iam_policy_document" "court_hearings_large_messages_bucket_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${data.aws_ssm_parameter.court_hearings_large_messages_bucket_arn.value}/*",
    ]
  }
}