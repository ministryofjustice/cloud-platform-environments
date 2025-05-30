resource "random_id" "athena-id" {
  byte_length = 16
}

resource "aws_iam_user" "athena-user" {
  name = "athena-user-${random_id.athena-id.hex}"
  path = "/system/athena-user/"
}

resource "aws_iam_access_key" "athena-user" {
  user = aws_iam_user.athena-user.name
}

data "aws_iam_policy_document" "athena" {
  statement {
    actions = [
      "athena:StartQueryExecution",
      "athena:GetQueryResults",
      "athena:GetQueryExecution",

      "s3:PutObject",
      "s3:GetObject",
      "s3:ListBucket",

      "glue:GetDatabase",
      "glue:GetTable",
      "glue:GetPartition",
    ]

    resources = [
      aws_athena_workgroup.queries.arn,
      "arn:aws:athena:eu-west-2:*:queryexecution/*",
      "arn:aws:glue:eu-west-2:*:catalog",
      aws_glue_catalog_database.audit_glue_catalog_database.arn,
      aws_glue_catalog_table.audit_event_table.arn,
      module.s3.bucket_arn,
      "${module.s3.bucket_arn}/*"
    ]
  }
}


resource "aws_iam_user_policy" "athena-policy" {
  name   = "${var.namespace}-athena"
  policy = data.aws_iam_policy_document.athena.json
  user   = aws_iam_user.athena-user.name
}

resource "kubernetes_secret" "audit_athena_iam" {
  metadata {
    name      = "athena-iam"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.athena-user.id
    secret_access_key = aws_iam_access_key.athena-user.secret
  }
}
