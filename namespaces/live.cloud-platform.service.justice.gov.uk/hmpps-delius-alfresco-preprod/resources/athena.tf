locals {
  inventory_base          = "s3://${module.s3_inventory_reports.bucket_name}/${var.inventory_prefix}"
  athena_results_location = "s3://${module.s3_inventory_reports.bucket_name}/query_results/"
  expected_keys_location  = coalesce(var.expected_keys_location, "s3://${module.s3_inventory_reports.bucket_name}/expected-keys/")
}

# Glue database (follows audit naming convention)
resource "aws_glue_catalog_database" "alfresco_glue" {
  name         = "hmpps_alfresco_${var.environment_name}_glue_catalog_db"
  location_uri = "s3://${module.s3_inventory_reports.bucket_name}/"
}

# Athena workgroup (follows audit pattern)
resource "aws_athena_workgroup" "alfresco_queries" {
  name = "hmpps_alfresco_${var.environment_name}"
  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
    result_configuration { output_location = local.athena_results_location }
  }
}

# Glue table over S3 Inventory (Parquet) with partition projection on dt
resource "aws_glue_catalog_table" "s3_inventory" {
  database_name = aws_glue_catalog_database.alfresco_glue.name
  name          = "s3_inventory"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    classification               = "parquet"
    EXTERNAL                     = "TRUE"
    "projection.enabled"         = "true"
    "projection.dt.type"         = "date"
    "projection.dt.range"        = "2016-01-01,NOW"
    "projection.dt.format"       = "yyyy-MM-dd"
    "storage.location.template"  = "${local.inventory_base}/dt=$${dt}/"
  }

  partition_keys {
    name = "dt"
    type = "string"
  }

  storage_descriptor {
    location      = local.inventory_base
    input_format  = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.parquet.MapredParquetOutputFormat"
    compressed    = true
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.ql.io.parquet.serde.ParquetHiveSerDe"
      parameters = { "serialization.format" = "1" }
    }
    columns {
      name = "bucket"
      type = "string"
    }
    columns {
      name = "key"
      type = "string"
    }
    columns {
      name = "size"
      type = "bigint"
    }
    columns {
      name = "etag"
      type = "string"
    }
    columns {
      name = "storageclass"
      type = "string"
    }
    columns {
      name = "islatest"
      type = "boolean"
    }
    columns {
      name = "isdeletemarker"
      type = "boolean"
    }
    columns {
      name = "lastmodifieddate"
      type = "timestamp"
    }
    columns {
      name = "encryptionstatus"
      type = "string"
    }
  }
}

# Glue table for the expected keys CSV exported from RDS
resource "aws_glue_catalog_table" "expected_keys" {
  database_name = aws_glue_catalog_database.alfresco_glue.name
  name          = "expected_keys"
  table_type    = "EXTERNAL_TABLE"

  parameters = {
    EXTERNAL                  = "TRUE"
    "skip.header.line.count"  = "0"
    classification            = "csv"
  }

  storage_descriptor {
    location      = local.expected_keys_location
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    ser_de_info {
      serialization_library = "org.apache.hadoop.hive.serde2.OpenCSVSerde"
      parameters = { 
          separatorChar = ",", 
          quoteChar = "\"", 
          escapeChar = "\\" 
      }
    }
    columns {
      name = "key"
      type = "string"
    }
    columns {
      name = "content_size"
      type = "bigint"
    }
  }
}

# K8s secrets (same shapes/names as audit)
resource "kubernetes_secret" "glue_database_name" {
  metadata { 
    name = "glue-database-name"
    namespace = var.namespace
  }
  data = {
    database_arn  = aws_glue_catalog_database.alfresco_glue.arn
    database_name = aws_glue_catalog_database.alfresco_glue.name
  }
}

resource "kubernetes_secret" "glue_catalog_table_name" {
  metadata { 
    name = "glue-catalog-table-name"
    namespace = var.namespace
  }
  data = {
    table_arn  = aws_glue_catalog_table.s3_inventory.arn
    table_name = aws_glue_catalog_table.s3_inventory.name
  }
}

resource "kubernetes_secret" "expected_keys_glue_catalog_table_name" {
  metadata { 
    name = "expected-keys-glue-catalog-table-name"
    namespace = var.namespace
  }
  data = {
    table_arn  = aws_glue_catalog_table.expected_keys.arn
    table_name = aws_glue_catalog_table.expected_keys.name
  }
}

resource "kubernetes_secret" "athena_workgroup" {
  metadata { 
    name = "athena-workgroup-secret"
    namespace = var.namespace
  }
  data = {
    workgroup_arn  = aws_athena_workgroup.alfresco_queries.arn
    workgroup_name = aws_athena_workgroup.alfresco_queries.name
  }
}

resource "kubernetes_secret" "athena_output_location" {
  metadata { 
    name = "athena-output-location-secret"
    namespace = var.namespace
  }
  data = { output_location = local.athena_results_location }
}