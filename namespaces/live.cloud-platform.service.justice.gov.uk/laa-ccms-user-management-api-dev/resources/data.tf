data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/rajinder-pocs/sqs-queue-arn" #--Producer namespace
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/rajinder-pocs/sqs-policy-arn" #--Producer namespace
}