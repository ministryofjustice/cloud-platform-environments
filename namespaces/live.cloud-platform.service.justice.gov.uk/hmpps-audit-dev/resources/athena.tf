resource "aws_glue_catalog_database" "audit_glue_catalog_database" {
  name = "hmpps_audit_${var.environment-name}_glue_catalog_db"
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
  database_name = aws_glue_catalog_database.audit_glue_catalog_database.name
  name          = "audit_events"

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
      name = "when"
      type = "string"
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

resource "kubernetes_secret" "glue-database-name-secret" {
  metadata {
    name      = "glue-database-name"
    namespace = var.namespace
  }
  data = {
    database_arn  = aws_glue_catalog_database.audit_glue_catalog_database.arn
    database_name = aws_glue_catalog_database.audit_glue_catalog_database.name
  }
}

resource "kubernetes_secret" "glue-catalog-table-name-secret" {
  metadata {
    name      = "glue-catalog-table-name"
    namespace = var.namespace
  }
  data = {
    table_arn  = aws_glue_catalog_table.audit_event_table.arn
    table_name = aws_glue_catalog_table.audit_event_table.name
  }
}

resource "kubernetes_secret" "athena-workgroup-secret" {
  metadata {
    name      = "athena-workgroup-secret"
    namespace = var.namespace
  }
  data = {
    workgroup_arn  = aws_athena_workgroup.queries.arn
    workgroup_name = aws_athena_workgroup.queries.name
  }
}

resource "kubernetes_secret" "athena-output-location-secret" {
  metadata {
    name      = "athena-output-location-secret"
    namespace = var.namespace
  }
  data = {
    output_location = "s3://${module.s3.bucket_name}/"
  }
}
