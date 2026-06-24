locals {
    glue_s3_targets = [
        "s3://coat-${local.environment}-cur-v2-hourly/moj-cost-and-usage-reports/MOJ-CUR-V2-HOURLY/data/",
        "s3://coat-${local.environment}-cur-v2-hourly-enriched/"
    ]
}

resource "aws_iam_role" "copilot_credits_dev_glue_role" {
  name = "copilot_credits_dev_glue_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "glue.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "copilot_credits_dev_glue_s3_policy" {
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  role = aws_iam_role.copilot_credits_dev_glue_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = ["s3:GetObject", "s3:ListBucket"],
        Resource = [
          "${module.s3_bucket.bucket_arn}/*",
          module.s3_bucket.bucket_arn
        ]
      },
      {
        Sid    = "AthenaAccess",
        Effect = "Allow",
        Action = [
          "athena:GetDatabase",
          "athena:GetDataCatalog",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetTableMetadata",
          "athena:GetWorkGroup",
          "athena:ListDatabases",
          "athena:ListDataCatalogs",
          "athena:ListWorkGroups",
          "athena:ListTableMetadata",
          "athena:StartQueryExecution",
          "athena:StopQueryExecution"
        ],
        Resource = ["*"]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "copilot_credits_dev_glue_service_role_attachment" {
  role       = aws_iam_role.copilot_credits_dev_glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

resource "aws_glue_catalog_database" "copilot_credits_dev_database" {
  name = "copilot_credits_dev_database"
}

resource "aws_glue_crawler" "copilot_credits_dev_crawler" {
  #checkov:skip=CKV_AWS_195: "Ensure Glue component has a security configuration associated"

  name          = "copilot_credits_dev_crawler"
  database_name = aws_glue_catalog_database.copilot_credits_dev_database.name
  role          = aws_iam_role.copilot_credits_dev_glue_role.arn

  s3_target {
    path = "s3://${module.s3_bucket.bucket_name}/reports/"
  }

  configuration = jsonencode({
    Version = 1.0,
    CrawlerOutput = {
      Tables = {
        AddOrUpdateBehavior = "MergeNewColumns"
      }
    }
  })

  schedule = "cron(0 7 * * ? *)"
}

resource "aws_athena_workgroup" "copilot_credits_dev_workgroup" {
  name = "copilot_credits_dev_workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${module.s3_bucket.bucket_name}/athena-results/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true
  }
}