resource "aws_iam_user" "athena-user" {
  name = "${var.namespace}-athena-user"
  path = "/system/${var.namespace}/athena-user/"
}

resource "aws_iam_access_key" "athena-user" {
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
      "athena:GetTableMetadata",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectTagging",
      "s3:PutObject",
      "s3:PutObjectTagging",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:DescribeJob",
      "s3:ListMultipartUploadParts",
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
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "athena-policy" {
  name   = "${var.namespace}-athena-policy"
  user   = aws_iam_user.athena-user.name
  policy = data.aws_iam_policy_document.athena.json
}

resource "kubernetes_secret" "athena-secret" {
  metadata {
    name      = "athena"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.athena-user.id
    secret_access_key = aws_iam_access_key.athena-user.secret
    user_arn          = aws_iam_user.athena-user.arn
    user_id           = aws_iam_user.athena-user.unique_id
    user_name         = aws_iam_user.athena-user.name
    policy_id         = aws_iam_user_policy.athena-policy.id
    database_id       = aws_athena_database.database.id
    database_name     = aws_athena_database.database.name
    workgroup         = aws_athena_workgroup.queries.name
  }
}
