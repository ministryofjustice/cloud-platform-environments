data "aws_iam_policy_document" "ssm_policy" {
  statement {
    actions = [
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:PutParameter"
    ]
    resources = [
      aws_ssm_parameter.data_store_cpr_ingestion_role_arn_dev.arn,
      aws_ssm_parameter.data_store_cemo_ingestion_role_arn_dev.arn,
      aws_ssm_parameter.data_store_cpr_ingestion_role_arn_test.arn,
      aws_ssm_parameter.data_store_cemo_ingestion_role_arn_test.arn,
    ]
  }

}

resource "aws_iam_policy" "ssm_access" {
  name   = "${var.namespace}-ssm-policy"
  policy = data.aws_iam_policy_document.ssm_policy.json
  tags   = local.tags
}

# data "aws_iam_policy_document" "cross_account_policy" {
#   statement {
#     actions = [
#       "sts:AssumeRole"
#     ]
#     resources = [
#       # data.aws_ssm_parameter.data_store_cpr_ingestion_role_arn_dev.value,
#       # data.aws_ssm_parameter.data_store_cemo_ingestion_role_arn_dev.value,
#       # data.aws_ssm_parameter.data_store_cpr_ingestion_role_arn_test.value,
#       # data.aws_ssm_parameter.data_store_cemo_ingestion_role_arn_test.value,
#     ]
#   }
# }

# resource "aws_iam_policy" "cross_account_access" {
#   name   = "${var.namespace}-cross-account-policy-general"
#   policy = data.aws_iam_policy_document.cross_account_policy.json
#   tags   = local.tags
# }
