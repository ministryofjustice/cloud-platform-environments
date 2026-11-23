
data "aws_ssm_parameter" "court-cases-topic-arn" {
  name = "/court-probation-test/court-cases-topic-arn"
}

data "aws_ssm_parameter" "large-court-cases-s3-bucket-name" {
  name = "/court-probation-test/large-court-cases-s3-bucket-name"
}

data "aws_ssm_parameter" "large-court-cases-s3-bucket-arn" {
  name = "/court-probation-test/large-court-cases-s3-bucket-arn"
}