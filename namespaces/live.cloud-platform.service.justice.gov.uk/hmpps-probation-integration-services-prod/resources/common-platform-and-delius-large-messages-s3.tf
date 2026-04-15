data "aws_ssm_parameter" "court_hearings_large_messages_bucket_policy" {
  name = "/court-probation-${var.environment_name}/large-court-cases-s3-bucket-policy"
}