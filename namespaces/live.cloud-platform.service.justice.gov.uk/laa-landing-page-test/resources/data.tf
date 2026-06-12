data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/laa-ccms-user-management-api-test/sqs-queue-arn"
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/laa-ccms-user-management-api-test/sqs-policy-arn"
}