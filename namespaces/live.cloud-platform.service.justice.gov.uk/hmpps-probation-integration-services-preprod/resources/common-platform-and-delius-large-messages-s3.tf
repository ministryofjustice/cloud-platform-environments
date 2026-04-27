
data "aws_ssm_parameter" "court_hearings_large_messages_bucket_name" {
  name = "/hmpps-person-record-${var.environment_name}/cpr-large-court-cases-s3-bucket-name"
}

data "aws_ssm_parameter" "court_hearings_large_messages_bucket_arn-preprod" {
  name = "/hmpps-person-record-${var.environment_name}/cpr-large-court-cases-s3-bucket-arn"
}
# data "aws_iam_policy_document" "court_hearings_large_messages_bucket_policy_document-preprod" {
#   statement {
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:DeleteObject"
#     ]
#
#     resources = [
#       "${data.aws_ssm_parameter.court_hearings_large_messages_bucket_arn-preprod.value}/*",
#     ]
#   }
# }
#
# resource "aws_iam_policy" "court_hearings_large_messages_bucket_policy-preprod" {
#   name = "${var.namespace}-court-hearings-large-messages-bucket-policy-preprod"
#   policy = data.aws_iam_policy_document.court_hearings_large_messages_bucket_policy_document-preprod.json
#   tags = {
#     business_unit          = var.business_unit
#     application            = var.application
#     environment_name       = var.environment_name
#     infrastructure_support = var.infrastructure_support
#     is_production          = var.is_production
#     owner                  = var.team_name
#   }
# }