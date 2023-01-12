resource "aws_athena_database" "database" {
  name   = "pathfinder_${var.environment-name}"
  bucket = module.pathfinder_reporting_s3_bucket.bucket_name
  force_destroy = true
}

resource "aws_athena_workgroup" "queries" {
  name = "pathfinder_${var.environment-name}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.pathfinder_reporting_s3_bucket.bucket_name}/query_results/"
    }
  }

  depends_on = [module.pathfinder_reporting_s3_bucket]
}
