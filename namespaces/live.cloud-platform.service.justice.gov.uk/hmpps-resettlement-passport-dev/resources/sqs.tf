resource "aws_sqs_queue" "sh_queue" {
  name                       = "dev-standard-queue"
  delay_seconds              = 0
  visibility_timeout_seconds = 30
  max_message_size           = 2048
  receive_wait_time_seconds  = 2
  sqs_managed_sse_enabled = true
}