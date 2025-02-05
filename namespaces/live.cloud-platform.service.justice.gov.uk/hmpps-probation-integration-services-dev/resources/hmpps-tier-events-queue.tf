data "aws_sqs_queue" "hmpps-tier-events-queue" {
  name = "${var.team_name}-${var.environment_name}-hmpps-tier-events-queue"
}

data "aws_sqs_queue" "hmpps-tier-events-dlq" {
  name = "${var.team_name}-${var.environment_name}-hmpps-tier-events-dlq"
}