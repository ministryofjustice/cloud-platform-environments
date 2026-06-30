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