data "aws_ssm_parameter" "prod-court-cases-topic-arn" {
  name = "/court-probation-prod/court-cases-topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-preprod/topic-arn"
}

data "aws_ssm_parameter" "prod-large-court-cases-s3-bucket-arn" {
  name = "/court-probation-prod/large-court-cases-s3-bucket-arn"
}

