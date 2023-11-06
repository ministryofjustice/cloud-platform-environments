data "aws_ssm_parameter" "court-case-events-topic-arn" {
  name = "topic_arn"
}