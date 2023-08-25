resource "aws_ssm_parameter" "tf-output-basm-irsa-policy" {
  type     = "String"
  name     = "/${var.namespace}/reporting-bucket/irsa-policy-arn"
  value    = module.book_a_secure_move_reporting_s3_bucket.irsa_policy_arn
}

resource "aws_ssm_parameter" "tf-output-basm-reporting-bucket" {
  type     = "String"
  name     = "/${var.namespace}/reporting-bucket/bucket-name"
  value    = module.book_a_secure_move_reporting_s3_bucket.bucket_name
}