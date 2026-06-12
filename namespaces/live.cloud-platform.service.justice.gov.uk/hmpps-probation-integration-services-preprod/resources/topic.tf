data "aws_sns_topic" "hmpps-domain-events" {
  name = "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd"
}

data "aws_ssm_parameter" "hmpps-domain-events-policy-arn" {
  name = "/hmpps-domain-events-${var.environment_name}/sns/${data.aws_sns_topic.hmpps-domain-events.name}/irsa-policy-arn"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-dbe10e8d9c1f4d100f0c723d5d9b754e"
}

data "aws_ssm_parameter" "probation-offender-events-policy-arn" {
  name = "/offender-events-${var.environment_name}/sns/${data.aws_sns_topic.probation-offender-events.name}/irsa-policy-arn"
}

# Temporary - reading from production topic into pre-production
data "aws_sns_topic" "probation-offender-events-prod" {
  name = "cloud-platform-Digital-Prison-Services-c2d997878cd24eef94e60f1404977153"
}

data "aws_ssm_parameter" "probation-offender-events-prod-policy-arn" {
  name = "/offender-events-prod/sns/${data.aws_sns_topic.probation-offender-events-prod.name}/irsa-policy-arn"
}

data "aws_sns_topic" "prison-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-d448bb61bb0b69b82fb19a3fa574e7f9"
}

data "aws_ssm_parameter" "court-topic" {
  name = "/hmpps-person-record-preprod/cpr-court-topic-sns-arn"
}

data "aws_ssm_parameter" "court-topic-prod" {
  name = "/hmpps-person-record-prod/cpr-court-topic-sns-arn"
}
