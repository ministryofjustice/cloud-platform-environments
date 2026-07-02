# Glue crawler role

resource "aws_iam_role" "copilot_credits_prod_glue_role" {
  name = "copilot_credits_prod_glue_role"

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

resource "aws_iam_role_policy" "copilot_credits_prod_glue_s3_policy" {
  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
  #checkov:skip=CKV_AWS_290: "Ensure IAM policies does not allow write access without constraints"
  role = aws_iam_role.copilot_credits_prod_glue_role.name

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
        Resource = [
          "arn:aws:athena:eu-west-2:*:queryexecution/*",
          "arn:aws:glue:eu-west-2:*:catalog",
          aws_athena_workgroup.copilot_credits_prod_workgroup.arn
        ]
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "copilot_credits_prod_glue_service_role_attachment" {
  role       = aws_iam_role.copilot_credits_prod_glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Athena IRSA policy

data "aws_iam_policy_document" "copilot_credits_prod_athena_irsa_policy_document" {
  version = "2012-10-17"
  statement {
    sid    = "AllowAthenaQueries"
    effect = "Allow"
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryExecution",
      "athena:GetQueryResults"
    ]
    resources = [
      "arn:aws:athena:eu-west-2:*:queryexecution/*",
      aws_athena_workgroup.copilot_credits_prod_workgroup.arn
    ]
  }

  statement {
    sid    = "AllowGlueCatalog"
    effect = "Allow"
    actions = [
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:StartCrawler",
      "glue:GetCrawler"
    ]
    resources = [
      "arn:aws:glue:eu-west-2:*:catalog",
      aws_glue_catalog_database.copilot_credits_prod_database.arn,
      "${aws_glue_catalog_database.copilot_credits_prod_database.arn}/credits_by_model",
      "${aws_glue_catalog_database.copilot_credits_prod_database.arn}/credits_by_user",
      aws_glue_crawler.copilot_credits_prod_crawler.arn
    ]
  }

  statement {
    sid    = "AllowCloudWatch"
    effect = "Allow"
    actions = [
      "logs:GetLogEvents",
      "logs:DescribeLogStreams",
      "logs:DescribeLogGroups",
      "logs:FilterLogEvents"
    ]
    resources = [
      "arn:aws:logs:eu-west-2:${data.aws_caller_identity.current.account_id}:log-group:/aws-glue/crawlers:${aws_glue_crawler.copilot_credits_prod_crawler.name}",
    ]
  }
}

resource "aws_iam_policy" "copilot_credits_prod_athena_irsa_policy" {
  name   = "copilot_credits_prod_athena_irsa_policy"
  policy = data.aws_iam_policy_document.copilot_credits_prod_athena_irsa_policy_document.json
}