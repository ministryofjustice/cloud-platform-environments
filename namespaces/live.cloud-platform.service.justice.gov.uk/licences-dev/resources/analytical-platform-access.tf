module "ap_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.ap_policy.arn]
  service_account  = "${var.namespace}-to-ap-s3"
}

resource "aws_iam_policy" "ap_policy" {
  name   = "${var.namespace}-ap-policy"
  policy = data.aws_iam_policy_document.licences_ap_access.json
}

data "aws_iam_policy_document" "licences_ap_access" {
  statement {
    sid = "AllowRdsExportUserToListS3Buckets"
    actions = [
      "s3:ListBucket",
      "s3:GetBucketLocation"
    ]

    resources = [
      "arn:aws:s3:::*"
    ]
  }

  statement {
    sid = "AllowRdsExportUserWriteToS3"
    actions = [
      "s3:PutObject*",
      "s3:PutObjectAcl",
      "s3:GetObject*",
      "s3:DeleteObject*"
    ]

    resources = [
      "arn:aws:s3:::moj-reg-dev/landing/licences-dev/*",
      "arn:aws:s3:::moj-reg-dev/landing/licences-dev/"
    ]
  }
}

resource "random_id" "licences-ap-id" {
  byte_length = 16
}

resource "aws_iam_user" "licences_ap_user" {
  name = "licences-ap-s3-bucket-user-${random_id.licences-ap-id.hex}"
  path = "/system/licences-ap-s3-bucket-user/"
}

resource "aws_iam_access_key" "licences_ap_user" {
  user = aws_iam_user.licences_ap_user.name
}

resource "aws_iam_user_policy" "licences_ap_policy" {
  name   = "${var.namespace}-ap-s3-snapshots"
  policy = data.aws_iam_policy_document.licences_ap_access.json
  user   = aws_iam_user.licences_ap_user.name
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "licences-analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://moj-reg-dev/landing/licences-dev/"
    user_arn           = aws_iam_user.licences_ap_user.arn
    access_key_id      = aws_iam_access_key.licences_ap_user.id
    secret_access_key  = aws_iam_access_key.licences_ap_user.secret
  }
}

resource "kubernetes_secret" "ap_irsa" {
  metadata {
    name      = "licences-to-ap-s3-irsa"
    namespace = var.namespace
  }

  data = {
    role           = module.ap_irsa.aws_iam_role_name
    serviceaccount = module.ap_irsa.service_account_name.name
  }
}
