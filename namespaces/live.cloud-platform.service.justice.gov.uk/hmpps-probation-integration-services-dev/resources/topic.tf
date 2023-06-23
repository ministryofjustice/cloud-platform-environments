data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573"
}

data "aws_ssm_parameter" "hmpps-domain-events-policy-arn" {
  name = "/hmpps-domain-events-${var.environment_name}/sns/${data.aws_sns_topic.hmpps-domain-events.name}/irsa-policy-arn"
}

data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-f221e27fcfcf78f6ab4f4c3cc165eee7"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-453cac1179377186788c5fcd12525870"
}

data "aws_ssm_parameter" "probation-offender-events-policy-arn" {
  name = "/offender-events-${var.environment_name}/sns/${data.aws_sns_topic.probation-offender-events.name}/irsa-policy-arn"
}
