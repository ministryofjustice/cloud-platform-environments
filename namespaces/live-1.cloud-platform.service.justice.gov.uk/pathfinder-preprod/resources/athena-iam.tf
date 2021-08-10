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
      "athena:StartQueryExecution",
      "athena:GetQueryResults",
      "s3:ListMultipartUploadParts",
      "athena:GetWorkGroup",
      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:DescribeJob",
      "s3:AbortMultipartUpload",
      "athena:CancelQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryExecution",
      "glue:BatchCreatePartition",
      "glue:GetDatabase",
      "glue:GetDatabases",
      "glue:GetTable",
      "glue:CreateTable",
      "glue:DeleteTable",
      "glue:GetPartitions",
    ]

    resources = [
      "${aws_athena_workgroup.queries.arn}",
      "${aws_athena_workgroup.queries.arn}/*",
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
