resource "random_id" "athena-id" {
  byte_length = 16
}

resource "aws_iam_user" "athena-user" {
  name = "pathfinder-athena-user-${random_id.athena-id.hex}"
  path = "/system/pathfinder-athena-user/"
}

resource "aws_iam_access_key" "pathfinder-athena-user" {
  user = aws_iam_user.athena-user.name
}

data "aws_iam_policy_document" "athena" {

  statement {
    actions = [
      "athena:ListWorkGroups",
      "athena:ListEngineVersions",
      "athena:ListDataCatalogs",
      "athena:GetCatalogs",
      "athena:ListDatabases",
      "athena:ListTableMetadata",
      "athena:GetTableMetadata"
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:ListMultipartUploadParts",
      "s3:PutObject",
      "s3:GetObject",
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "s3:DescribeJob",
      "s3:AbortMultipartUpload",
      "athena:BatchGetNamedQuery",
      "athena:BatchGetQueryExecution",
      "athena:GetExecutionEngine",
      "athena:GetExecutionEngines",
      "athena:GetNamedQuery",
      "athena:GetNamespace",
      "athena:GetNamespaces",
      "athena:GetQueryExecution",
      "athena:GetQueryExecutions",
      "athena:GetQueryResults",
      "athena:GetQueryResultsStream",
      "athena:GetTable",
      "athena:GetTables",
      "athena:GetWorkGroup",
      "athena:ListNamedQueries",
      "athena:ListQueryExecutions",
      "athena:ListTagsForResource",
      "athena:ListWorkGroups",
      "athena:StartQueryExecution",
      "athena:StopQueryExecution",
      "athena:CancelQueryExecution",
      "athena:GetDatabase",
      "glue:BatchCreatePartition",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetPartition",
      "glue:GetPartitions",
      "glue:GetTable",
      "glue:GetTables",
      "glue:GetTableVersion",
      "glue:GetTableVersions",
      "glue:CreateTable",
      "glue:DeleteTable",
    ]

    resources = [
      aws_athena_workgroup.queries.arn,
      "${aws_athena_workgroup.queries.arn}/*",
      "arn:aws:athena:eu-west-2:*:datacatalog/AwsDataCatalog",
      "arn:aws:glue:eu-west-2:*:catalog",
      "arn:aws:glue:eu-west-2:*:database/${aws_athena_database.database.id}",
      "arn:aws:glue:eu-west-2:*:table/${aws_athena_database.database.id}",
      "arn:aws:glue:eu-west-2:*:table/${aws_athena_database.database.id}/*",
      module.pathfinder_reporting_s3_bucket.bucket_arn,
      "${module.pathfinder_reporting_s3_bucket.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "athena-policy" {
  name   = "${var.namespace}-athena"
  policy = data.aws_iam_policy_document.athena.json
  user   = aws_iam_user.athena-user.name
}

resource "kubernetes_secret" "pathfinder_athena_iam" {
  metadata {
    name      = "pathfinder-athena-iam"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.pathfinder-athena-user.id
    secret_access_key = aws_iam_access_key.pathfinder-athena-user.secret
  }
}
