resource "aws_s3_bucket" "audit_s3_bucket_cloudtrail_logs" {
  bucket = module.cloudtrail_s3_bucket.name

  tags = {
    name = "audit_s3_bucket_cloudtrail_logs"
    environment_name = var.environment-name
  }
}
