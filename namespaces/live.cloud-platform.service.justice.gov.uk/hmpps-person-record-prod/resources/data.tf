data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-prod/topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}