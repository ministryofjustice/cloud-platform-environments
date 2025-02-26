data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}

data "aws_ssm_parameter" "cpr_court_topic_sns_arn" {
  name = "/hmpps-person-record-dev/cpr-court-topic-sns-arn"
}