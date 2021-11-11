data "aws_iam_policy_document" "reporting_access" {
  statement {
    sid = "AllowDataExportUserToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowDataExportUserToWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "arn:aws:s3:::eu-west-2-delius-stage-dfi-extracts/dfinterventions/dfi/*",
      "arn:aws:s3:::eu-west-2-delius-stage-dfi-extracts/dfinterventions/dfi/",
      "arn:aws:s3:::eu-west-2-delius-stage-dfi-extracts/exports/csv/reports/*",
      "arn:aws:s3:::eu-west-2-delius-stage-dfi-extracts/exports/csv/reports/"
    ]
  }
}

resource "random_id" "reporting_user_id" {
  byte_length = 16
}

resource "aws_iam_user" "reporting_user" {
  name = "reporting-s3-bucket-user-${random_id.reporting_user_id.hex}"
  path = "/system/reporting-s3-bucket-user/"
}

resource "aws_iam_access_key" "reporting_user" {
  user = aws_iam_user.reporting_user.name
}

resource "aws_iam_user_policy" "reporting_user_policy" {
  name   = "${var.namespace}-reporting-s3-snapshots"
  policy = data.aws_iam_policy_document.reporting_access.json
  user   = aws_iam_user.reporting_user.name
}

resource "kubernetes_secret" "reporting_aws_secret" {
  metadata {
    name      = "reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://eu-west-2-delius-stage-dfi-extracts/dfinterventions/dfi"
    user_arn           = aws_iam_user.reporting_user.arn
    access_key_id      = aws_iam_access_key.reporting_user.id
    secret_access_key  = aws_iam_access_key.reporting_user.secret
    bucket_name        = "eu-west-2-delius-stage-dfi-extracts"
  }
}
