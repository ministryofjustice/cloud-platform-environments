data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-prod/topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-c2d997878cd24eef94e60f1404977153"
}