resource "aws_athena_database" "database" {
  name   = replace(var.namespace, "-", "_")
  bucket = module.s3_bucket.bucket_name
}

resource "aws_athena_workgroup" "queries" {
  name = var.namespace

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3_bucket.bucket_name}/athena-results/"
    }
  }
}
