data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-dbe10e8d9c1f4d100f0c723d5d9b754e"
}

data "aws_ssm_parameter" "probation-offender-events-policy-arn" {
  name     = "/offender-events-${var.environment}/sns/${data.aws_sns_topic.probation-offender-events.name}/irsa-policy-arn"
}