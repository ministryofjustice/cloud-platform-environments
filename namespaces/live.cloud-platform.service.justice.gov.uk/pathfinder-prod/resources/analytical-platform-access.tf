resource "aws_iam_policy" "ap_policy" {
  name   = "${var.namespace}-ap-register-my-data-policy"
  policy = data.aws_iam_policy_document.pathfinder_ap_access.json
}

data "aws_iam_policy_document" "pathfinder_ap_access" {
  statement {
    sid = "AllowRdsExportUserWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::moj-reg-preprod/landing/hmpps-pathfinder-prod/*",
      "arn:aws:s3:::moj-reg-preprod/landing/hmpps-pathfinder-prod"
    ]
  }
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "pathfinder-analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://moj-reg-prod/landing/hmpps-${var.namespace}/"
  }
}
