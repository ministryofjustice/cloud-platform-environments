# Generate an additional IAM user to manage APIGW a
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
      "s3:ListMultipartUploadParts",
      "athena:GetWorkGroup",
      "s3:PutObject",
      "s3:GetObject",
      "s3:AbortMultipartUpload",
      "athena:CancelQueryExecution",
      "athena:StopQueryExecution",
      "athena:GetQueryExecution",
    "s3:GetBucketLocation"]

    resources = [
      "${aws_athena_workgroup.queries.arn}",
      "${aws_athena_workgroup.queries.arn}/*",
      "${module.track_a_move_s3_bucket.bucket_arn}/*",
    ]
  }
}

resource "aws_iam_user_policy" "athena-policy" {
  name   = "${var.namespace}-athena"
  policy = data.aws_iam_policy_document.athena.json
  user   = aws_iam_user.athena-user.name
}
