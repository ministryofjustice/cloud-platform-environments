resource "aws_athena_database" "database" {
  name   = "track_a_move_${var.environment_name}"
  bucket = module.track_a_move_s3_bucket.bucket_name
}


resource "aws_athena_workgroup" "queries" {
  name = "track_a_move_${var.environment_name}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.track_a_move_s3_bucket.bucket_name}/query_results/"
    }
  }
}
