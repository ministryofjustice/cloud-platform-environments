data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-prod/topic-arn"
}

data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-preprod/court-cases-topic-arn"
}