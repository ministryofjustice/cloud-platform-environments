data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-dev/court-cases-topic-arn"
}

data "aws_ssm_parameter" "hmpps-domain-events-topic-arn" {
  name = "/hmpps-domain-events-dev/topic-arn"
}

data "aws_ssm_parameter" "large-court-cases-s3-bucket-arn" {
  name = "/court-probation-dev/large-court-cases-s3-bucket-arn"
}

