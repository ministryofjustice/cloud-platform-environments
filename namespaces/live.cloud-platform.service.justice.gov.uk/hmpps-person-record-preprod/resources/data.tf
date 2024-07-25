data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-preprod/topic-arn"
}

data "aws_ssm_parameter" "court-case-events-fifo-topic-arn" {
  name = "/court-probation-preprod/fifo-topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-preprod/topic-arn"
}

data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-dbe10e8d9c1f4d100f0c723d5d9b754e"
}