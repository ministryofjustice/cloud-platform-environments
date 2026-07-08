data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/laa-ccms-user-management-api-dev/sqs-queue-arn"
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/laa-ccms-user-management-api-dev/sqs-policy-arn"
}