data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/rajinder-pocs/sqs-queue-arn" #--Producer namespace
}