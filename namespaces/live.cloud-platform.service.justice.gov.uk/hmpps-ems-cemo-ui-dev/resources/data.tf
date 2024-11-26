data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-dev/topic-arn"
}

data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-dev/court-cases-topic-arn"
}