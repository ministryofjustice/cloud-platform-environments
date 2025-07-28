data "aws_ssm_parameter" "prod-court-cases-topic-arn" {
  name = "/court-probation-prod/court-cases-topic-arn"
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

data "aws_ssm_parameter" "prod-large-court-cases-s3-bucket-arn" {
  name = "/court-probation-prod/large-court-cases-s3-bucket-arn"
}

