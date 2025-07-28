data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-prod/court-cases-topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

data "aws_sns_topic" "probation-offender-events" {
  name = "cloud-platform-Digital-Prison-Services-c2d997878cd24eef94e60f1404977153"
}

data "aws_ssm_parameter" "large-court-cases-s3-bucket-arn" {
  name = "/court-probation-prod/large-court-cases-s3-bucket-arn"
}