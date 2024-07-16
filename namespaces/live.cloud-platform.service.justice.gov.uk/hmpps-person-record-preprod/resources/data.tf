data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-preprod/topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-preprod/topic-arn"
}

data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-d448bb61bb0b69b82fb19a3fa574e7f9"
}