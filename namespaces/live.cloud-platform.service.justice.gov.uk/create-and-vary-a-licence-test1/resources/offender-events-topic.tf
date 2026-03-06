data "aws_ssm_parameter" "offender-events-topic-arn" {
  name = "/offender-events-dev/topic-arn"
}
