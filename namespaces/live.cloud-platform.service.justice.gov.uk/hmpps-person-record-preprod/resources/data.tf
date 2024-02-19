data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-preprod/topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-preprod/topic-arn"
}