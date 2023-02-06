resource "aws_athena_database" "database" {
  name   = "pathfinder_${var.environment-name}"
  bucket = module.pathfinder_reporting_s3_bucket.bucket_name
  force_destroy = true
}
