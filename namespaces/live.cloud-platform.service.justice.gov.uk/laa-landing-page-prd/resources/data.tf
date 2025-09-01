data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/laa-ccms-user-management-api-prod/sqs-queue-arn"
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/laa-ccms-user-management-api-prod/sqs-policy-arn"
}