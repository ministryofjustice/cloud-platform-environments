data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-preprod/court-cases-topic-arn"
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

data "aws_ssm_parameter" "large-court-cases-s3-bucket-name" {
  name = "/court-probation-preprod/large-court-cases-s3-bucket-name"
}

data "aws_ssm_parameter" "large-court-cases-s3-bucket-arn" {
  name = "/court-probation-preprod/large-court-cases-s3-bucket-arn"
}