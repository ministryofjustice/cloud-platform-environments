resource "random_id" "s3_local_user_id" {
  byte_length = 16
}

resource "aws_iam_user" "s3_local_user" {
  name = "s3-bucket-user-${random_id.s3_local_user_id.hex}"
  path = "/system/s3-bucket-user/"
}

resource "aws_iam_access_key" "s3_local_user" {
  user = aws_iam_user.s3_local_user.name
}

data "aws_iam_policy_document" "s3_local_access" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:ListBucketVersions",
      "s3:GetBucketLocation",
      "s3:GetBucketPolicy",
    ]
    resources = [
      module.s3_data_bucket.bucket_arn,
    ]
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject",
      "s3:DeleteObject",
    ]
    resources = [
      "${module.s3_data_bucket.bucket_arn}/*",
    ]
  }

  statement {
    sid     = "AssumeRekognitionRole"
    actions = ["sts:AssumeRole"]
    resources = [var.rekognition_role_arn]
  }
}

resource "aws_iam_user_policy" "s3_local_access" {
  name   = "s3-bucket-local-access"
  policy = data.aws_iam_policy_document.s3_local_access.json
  user   = aws_iam_user.s3_local_user.name
}

resource "kubernetes_secret" "s3_local_user" {
  metadata {
    name      = "hmpps-esupervision-s3-local-user"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.s3_local_user.id
    secret_access_key = aws_iam_access_key.s3_local_user.secret
  }
}
