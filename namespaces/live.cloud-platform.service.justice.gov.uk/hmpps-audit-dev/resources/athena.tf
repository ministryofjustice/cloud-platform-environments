resource "aws_athena_database" "database" {
  name   = "audit_${var.environment-name}"
  bucket = module.s3.bucket_name
}


resource "aws_athena_workgroup" "queries" {
  name = "track_a_move_${var.environment-name}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3.bucket_name}/query_results/"
    }
  }
}
