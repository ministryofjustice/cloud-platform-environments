data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-dev/topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-453cac1179377186788c5fcd12525870"
}