data "aws_sqs_queue" "supervision-packages-api-queue" {
  name = "${var.team_name}-${var.environment_name}-supervision-packages-api-queue"
}

data "aws_sqs_queue" "supervision-packages-api-dlq" {
  name = "${var.team_name}-${var.environment_name}-supervision-packages-api-dlq"
}