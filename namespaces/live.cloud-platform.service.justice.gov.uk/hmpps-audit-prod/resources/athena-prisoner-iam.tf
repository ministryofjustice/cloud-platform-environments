resource "random_id" "athena-prisoner-id" {
  byte_length = 16
}

resource "aws_iam_user" "athena-prisoner-user" {
  name = "athena-prisoner-user-${random_id.athena-prisoner-id.hex}"
  path = "/system/athena-user/"
}

resource "aws_iam_access_key" "athena-prisoner-user" {
  user = aws_iam_user.athena-prisoner-user.name
}

data "aws_iam_policy_document" "athena-prisoner" {
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
      aws_glue_catalog_database.prisoner_audit_glue_catalog_database.arn,
      aws_glue_catalog_table.prisoner_audit_event_table.arn,
      module.hmpps_prisoner_audit_s3.bucket_arn,
      "${module.hmpps_prisoner_audit_s3.bucket_arn}/*"
    ]
  }
}


resource "aws_iam_user_policy" "athena-prisoner-policy" {
  name   = "${var.namespace}-athena-prisoner"
  policy = data.aws_iam_policy_document.athena-prisoner.json
  user   = aws_iam_user.athena-prisoner-user.name
}

resource "kubernetes_secret" "audit_prisoner-athena_iam" {
  metadata {
    name      = "athena-prisoner-iam"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.athena-prisoner-user.id
    secret_access_key = aws_iam_access_key.athena-prisoner-user.secret
  }
}
