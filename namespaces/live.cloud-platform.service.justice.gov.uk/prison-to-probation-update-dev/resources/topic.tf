data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}

data "aws_ssm_parameter" "probation-offender-events-policy-arn" {
  name = "/offender-events-${var.environment}/sns/${data.aws_sns_topic.prison-offender-events.name}/irsa-policy-arn"
}