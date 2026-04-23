data "aws_ssm_parameter" "court_hearings_large_messages_bucket_policy" {
  name = "/hmpps-person-record-${var.environment_name}/large-court-cases-s3-bucket-policy"
}