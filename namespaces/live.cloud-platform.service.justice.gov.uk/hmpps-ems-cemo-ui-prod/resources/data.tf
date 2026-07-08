

data "aws_ssm_parameter" "large-court-cases-s3-bucket-name" {
  name = "/court-probation-prod/large-court-cases-s3-bucket-name"
}

data "aws_ssm_parameter" "large-court-cases-s3-bucket-arn" {
  name = "/court-probation-prod/large-court-cases-s3-bucket-arn"
}

data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-prod/court-cases-topic-arn"
}