data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-prod/topic-arn"
}

data "aws_ssm_parameter" "cpr-court-topic-sns-arn" {
  name = "/hmpps-person-record-prod/cpr-court-topic-sns-arn"
}

data "aws_ssm_parameter" "cpr-large-court-cases-s3-bucket-name" {
  name = "/hmpps-person-record-prod/cpr-large-court-cases-s3-bucket-name"
}

data "aws_ssm_parameter" "cpr-large-court-cases-s3-bucket-arn" {
  name = "/hmpps-person-record-prod/cpr-large-court-cases-s3-bucket-arn"
}