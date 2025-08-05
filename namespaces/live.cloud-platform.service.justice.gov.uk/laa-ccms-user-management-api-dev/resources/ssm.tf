data "aws_ssm_parameter" "sqs_queue_arn" {
  type = "String"
  name = "/rajinder-pocs/sqs-queue-arn" #--Producer namespace
}