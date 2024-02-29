data "aws_ssm_parameter" "offender-events-topic-arn" {
  name = "/offender-events-${var.environment_name}/topic-arn"
}
