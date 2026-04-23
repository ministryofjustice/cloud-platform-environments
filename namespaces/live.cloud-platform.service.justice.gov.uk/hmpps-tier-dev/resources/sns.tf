data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-${var.environment_name}/topic-arn"
}

data "aws_ssm_parameter" "probation-offender-events-topic-arn" {
  name = "/offender-events-${var.environment_name}/topic-arn"
}
