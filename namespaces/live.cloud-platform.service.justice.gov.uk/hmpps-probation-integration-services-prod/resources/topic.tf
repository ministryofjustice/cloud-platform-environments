data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08"
}

data "aws_ssm_parameter" "hmpps-domain-events-policy-arn" {
  name = "/hmpps-domain-events-${var.environment_name}/sns/${data.aws_sns_topic.hmpps-domain-events.name}/irsa-policy-arn"
}

data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-160f3055cc4e04c4105ee85f2ed1fccb"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-c2d997878cd24eef94e60f1404977153"
}

data "aws_ssm_parameter" "probation-offender-events-policy-arn" {
  name = "/offender-events-${var.environment_name}/sns/${data.aws_sns_topic.probation-offender-events.name}/irsa-policy-arn"
}
