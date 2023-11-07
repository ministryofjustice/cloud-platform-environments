data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "/court-probation-preprod/topic-arn"
}