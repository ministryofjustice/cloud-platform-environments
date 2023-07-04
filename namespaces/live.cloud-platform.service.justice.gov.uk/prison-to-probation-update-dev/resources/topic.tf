data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-453cac1179377186788c5fcd12525870"
}

data "aws_ssm_parameter" "probation-offender-events-policy-arn" {
  name = "/offender-events-${var.environment}/sns/${data.aws_sns_topic.probation-offender-events.name}/irsa-policy-arn"
}