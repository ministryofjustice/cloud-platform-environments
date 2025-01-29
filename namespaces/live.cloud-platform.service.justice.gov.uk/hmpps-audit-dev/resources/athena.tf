resource "aws_athena_database" "audit_database" {
  name   = "audit_${var.environment-name}"
  bucket = module.s3.bucket_name
}

resource "aws_athena_workgroup" "queries" {
  name = "hmpps_audit_${var.environment-name}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.s3.bucket_name}/query_results/"
    }
  }
}

resource "aws_athena_named_query" "audit_event_table" {
  name        = "audit_event_table"
  database    = aws_athena_database.audit_database.name

  query = <<EOT
    CREATE EXTERNAL TABLE IF NOT EXISTS audit_event (
      id STRING,
      what STRING,
      `when` STRING,
      operationId STRING,
      subjectId STRING,
      subjectType STRING,
      correlationId STRING,
      who STRING,
      service STRING,
      details STRING
    )
    PARTITIONED BY (
      year STRING,
      month STRING,
      day STRING,
      user STRING
    )
    STORED AS PARQUET
    LOCATION 's3://${module.s3.bucket_name}/'
    TBLPROPERTIES ("parquet.compression"="SNAPPY");
  EOT
}
