data "aws_ssm_parameter" "offender-events-topic-arn" {
  name = "/offender-events-${var.environment}/topic-arn"
}
