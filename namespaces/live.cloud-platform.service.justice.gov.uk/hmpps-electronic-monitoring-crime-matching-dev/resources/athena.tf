locals {
  # Mimic Datastore test environment
  mock_datastore_database_name = "acquisitive_crime_test_dbt"

  mock_datastore_prefix = "crime-matching-mock-datastore"

  data_bucket_name = "${local.mock_datastore_prefix}-test-data"
  workgroup_name = "${local.mock_datastore_prefix}-workgroup"
}

module "data_bucket" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-s3-bucket?ref=5.3.0"

  bucket_name = local.data_bucket_name

  team_name              = var.team_name
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_glue_catalog_database" "mock_datastore_database" {
  name = local.mock_datastore_database_name
  location_uri = "s3://${module.data_bucket.bucket_name}/"
  tags = local.tags
}

resource "aws_athena_workgroup" "mock_datastore_workgroup" {
  name = local.workgroup_name

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${module.data_bucket.bucket_name}/query_results/"
    }
  }

  tags = local.tags
}

resource "aws_glue_catalog_table" "caseload" {
  database_name = aws_glue_catalog_database.mock_datastore_database.name
  name          = "caseload"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    columns {
      name = "grouped_date"
      type = "timestamp"
    }

    columns {
      name = "unique_device_wearer_id"
      type = "string"
    }

    columns {
      name = "first_name"
      type = "string"
    }

    columns {
      name = "last_name"
      type = "string"
    }

    columns {
      name = "date_of_birth"
      type = "date"
    }

    columns {
      name = "house_number_and_street_name"
      type = "string"
    }

    columns {
      name = "city_or_town"
      type = "string"
    }

    columns {
      name = "county"
      type = "string"
    }

    columns {
      name = "country"
      type = "string"
    }

    columns {
      name = "postcode"
      type = "string"
    }

    columns {
      name = "nomis_id"
      type = "string"
    }

    columns {
      name = "pnc_id"
      type = "string"
    }

    columns {
      name = "mdss_person_id"
      type = "bigint"
    }

    columns {
      name = "order_id"
      type = "string"
    }

    columns {
      name = "order_start_date"
      type = "timestamp"
    }

    columns {
      name = "order_commencement_date"
      type = "timestamp"
    }

    columns {
      name = "order_end_date"
      type = "timestamp"
    }

    columns {
      name = "order_type"
      type = "string"
    }

    columns {
      name = "order_type_description"
      type = "string"
    }

    columns {
      name = "order_type_detail"
      type = "string"
    }

    columns {
      name = "responsible_organisation"
      type = "string"
    }

    columns {
      name = "responsible_officer_name"
      type = "string"
    }

    columns {
      name = "is_monitored"
      type = "boolean"
    }

    location      = "s3://${module.data_bucket.bucket_name}/caseload/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false
    
    ser_de_info {
      name                  = "caseload-csv-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"            = ","
        "serialization.format"   = ","
      }
    }
  }
}

resource "aws_glue_catalog_table" "device_activations" {
  database_name = aws_glue_catalog_database.mock_datastore_database.name
  name          = "device_activations"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    columns {
      name = "device_activation_id"
      type = "bigint"
    }

    columns {
      name = "device_activation_date"
      type = "timestamp"
    }

    columns {
      name = "device_deactivation_date"
      type = "timestamp"
    }

    columns {
      name = "person_id"
      type = "bigint"
    }

    columns {
      name = "device_id"
      type = "bigint"
    }

    columns {
      name = "device_serial_number"
      type = "string"
    }

    location      = "s3://${module.data_bucket.bucket_name}/device_activations/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false
    
    ser_de_info {
      name                  = "device-activations-csv-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"            = ","
        "serialization.format"   = ","
      }
    }
  }
}

resource "aws_glue_catalog_table" "position" {
  database_name = aws_glue_catalog_database.mock_datastore_database.name
  name          = "position"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    columns {
      name = "client_id"
      type = "bigint"
    }

    columns {
      name = "device_id"
      type = "bigint"
    }

    columns {
      name = "location_id"
      type = "bigint"
    }

    columns {
      name = "person_id"
      type = "bigint"
    }

    columns {
      name = "position_circulation_id"
      type = "bigint"
    }

    columns {
      name = "position_direction"
      type = "bigint"
    }

    columns {
      name = "position_geometry"
      type = "string"
    }

    columns {
      name = "position_gps_date"
      type = "timestamp"
    }

    columns {
      name = "position_hdop"
      type = "bigint"
    }

    columns {
      name = "position_id"
      type = "bigint"
    }

    columns {
      name = "position_latitude"
      type = "double"
    }

    columns {
      name = "position_lbs"
      type = "bigint"
    }

    columns {
      name = "position_longitude"
      type = "double"
    }

    columns {
      name = "position_precision"
      type = "bigint"
    }

    columns {
      name = "position_recorded_date"
      type = "timestamp"
    }

    columns {
      name = "position_satellite"
      type = "bigint"
    }

    columns {
      name = "position_speed"
      type = "bigint"
    }

    columns {
      name = "position_uploaded_date"
      type = "timestamp"
    }

    location      = "s3://${module.data_bucket.bucket_name}/position/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false
    
    ser_de_info {
      name                  = "position-csv-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"            = ","
        "serialization.format"   = ","
      }
    }
  }
}

resource "aws_glue_catalog_table" "orders_activations_positions" {
  database_name = aws_glue_catalog_database.mock_datastore_database.name
  name          = "orders_activations_positions"

  table_type = "EXTERNAL_TABLE"

  parameters = {
    "skip.header.line.count" = "1"
  }

  storage_descriptor {
    columns {
      name = "grouped_date"
      type = "timestamp"
    }

    columns {
      name = "unique_device_wearer_id"
      type = "string"
    }

    columns {
      name = "first_name"
      type = "string"
    }

    columns {
      name = "last_name"
      type = "string"
    }

    columns {
      name = "date_of_birth"
      type = "date"
    }

    columns {
      name = "house_number_and_street_name"
      type = "string"
    }

    columns {
      name = "city_or_town"
      type = "string"
    }

    columns {
      name = "county"
      type = "string"
    }

    columns {
      name = "country"
      type = "string"
    }

    columns {
      name = "postcode"
      type = "string"
    }

    columns {
      name = "nomis_id"
      type = "string"
    }

    columns {
      name = "pnc_id"
      type = "string"
    }

    columns {
      name = "mdss_person_id"
      type = "bigint"
    }

    columns {
      name = "order_id"
      type = "string"
    }

    columns {
      name = "order_start_date"
      type = "timestamp"
    }

    columns {
      name = "order_commencement_date"
      type = "timestamp"
    }

    columns {
      name = "order_end_date"
      type = "timestamp"
    }

    columns {
      name = "order_type"
      type = "string"
    }

    columns {
      name = "order_type_description"
      type = "string"
    }

    columns {
      name = "order_type_detail"
      type = "string"
    }

    columns {
      name = "responsible_organisation"
      type = "string"
    }

    columns {
      name = "responsible_officer_name"
      type = "string"
    }

    columns {
      name = "is_monitored"
      type = "boolean"
    }

    columns {
      name = "caseload__datetime_added"
      type = "timestamp"
    }

    columns {
      name = "device_activation_id"
      type = "bigint"
    }

    columns {
      name = "device_activation_date"
      type = "timestamp"
    }

    columns {
      name = "device_deactivation_date"
      type = "timestamp"
    }

    columns {
      name = "person_id"
      type = "bigint"
    }

    columns {
      name = "device_id"
      type = "bigint"
    }

    columns {
      name = "device_serial_number"
      type = "string"
    }

    columns {
      name = "device_activations__datetime_added"
      type = "timestamp"
    }

    columns {
      name = "client_id"
      type = "bigint"
    }

  columns {
      name = "location_id"
      type = "bigint"
    }

    columns {
      name = "position_circulation_id"
      type = "bigint"
    }

    columns {
      name = "position_direction"
      type = "bigint"
    }

    columns {
      name = "position_geometry"
      type = "string"
    }

    columns {
      name = "position_gps_date"
      type = "timestamp"
    }

    columns {
      name = "position_hdop"
      type = "bigint"
    }

    columns {
      name = "position_id"
      type = "bigint"
    }

    columns {
      name = "position_latitude"
      type = "double"
    }

    columns {
      name = "position_lbs"
      type = "bigint"
    }

    columns {
      name = "position_longitude"
      type = "double"
    }

    columns {
      name = "position_precision"
      type = "bigint"
    }

    columns {
      name = "position_recorded_date"
      type = "timestamp"
    }

    columns {
      name = "position_satellite"
      type = "bigint"
    }

    columns {
      name = "position_speed"
      type = "bigint"
    }

    columns {
      name = "position_uploaded_date"
      type = "timestamp"
    }

    location      = "s3://${module.data_bucket.bucket_name}/orders_activations_positions/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
    compressed    = false
    
    ser_de_info {
      name                  = "orders_activations_positions-csv-serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"

      parameters = {
        "field.delim"            = ","
        "serialization.format"   = ","
      }
    }
  }
}

## Policy for application / service pod to query Athena & manage test data in S3
data "aws_iam_policy_document" "mock_datastore_policy" {
  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution",
      "athena:GetWorkGroup",
    ]

    resources = [
      aws_athena_workgroup.mock_datastore_workgroup.arn,
      "arn:aws:athena:eu-west-2:*:queryexecution/*",
    ]
  }

  statement {
    sid = "ManageTestDataInS3"

    actions = [
      "s3:DeleteObject",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:PutObject",
    ]

    resources = [
      module.data_bucket.bucket_arn,
      "${module.data_bucket.bucket_arn}/*",
    ]
  }

  statement {
    actions = [
      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartition",
    ]

    resources = [
      "arn:aws:glue:eu-west-2:*:catalog",
      aws_glue_catalog_database.mock_datastore_database.arn,
      aws_glue_catalog_table.caseload.arn,
      aws_glue_catalog_table.device_activations.arn,
      aws_glue_catalog_table.position.arn,
      aws_glue_catalog_table.orders_activations_positions.arn,
    ]
  }
}

## Allow application / algorithm / service pod to assume mock datastore role
data "aws_iam_policy_document" "mock_datastore_assume_role_policy" {
  statement {
    sid     = "AllowAssumeRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [
        module.irsa.role_arn,
        module.crime_matching_algorithm_irsa.role_arn,
      ]
    }
  }
}

## Create the assume role
resource "aws_iam_role" "mock_datastore_role" {
  name               = "crime-matching-mock-datastore-role"
  assume_role_policy = data.aws_iam_policy_document.mock_datastore_assume_role_policy.json
}

## Attach Athena / S3 / Glue policy
resource "aws_iam_role_policy" "mock_datastore_policy" {
  name = "crime-matching-mock-datastore-policy"
  role = aws_iam_role.mock_datastore_role.id

  policy = data.aws_iam_policy_document.mock_datastore_policy.json
}

resource "kubernetes_secret" "mock_datastore_role" {
  metadata {
    name      = "mock-datastore-roles"
    namespace = var.namespace
  }
  type = "Opaque"
  data = {
    general_role_arn = aws_iam_role.mock_datastore_role.arn
  }
}
