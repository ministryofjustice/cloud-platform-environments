resource "aws_glue_catalog_database" "audit_database" {
  name = "audit_${var.environment-name}"
  location_uri = "s3://${module.s3.bucket_name}/"
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

resource "aws_glue_catalog_table" "audit_event_table" {
  database_name = aws_glue_catalog_database.audit_database.name
  name          = "audit_event"

  table_type = "EXTERNAL_TABLE"

  storage_descriptor {
    columns {
      name = "id"
      type = "string"
    }
    columns {
      name = "what"
      type = "string"
    }
    columns {
      name = "`when`"
      type = "timestamp"
    }
    columns {
      name = "operationId"
      type = "string"
    }
    columns {
      name = "subjectId"
      type = "string"
    }
    columns {
      name = "subjectType"
      type = "string"
    }
    columns {
      name = "correlationId"
      type = "string"
    }
    columns {
      name = "who"
      type = "string"
    }
    columns {
      name = "service"
      type = "string"
    }
    columns {
      name = "details"
      type = "string"
    }

    location      = "s3://${module.s3.bucket_name}/"
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    compressed    = true
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
    }

    stored_as_sub_directories = false
  }

  partition_keys {
    name = "year"
    type = "string"
  }

  partition_keys {
    name = "month"
    type = "string"
  }

  partition_keys {
    name = "day"
    type = "string"
  }

  partition_keys {
    name = "user"
    type = "string"
  }

  parameters = {
    EXTERNAL              = "TRUE"
    "parquet.compression" = "SNAPPY"
  }
}
