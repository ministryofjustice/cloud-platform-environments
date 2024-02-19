module "ap_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = {
    s3 = aws_iam_policy.ap_policy.arn
  }
  service_account_name = "${var.namespace}-to-ap-s3"
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "ap_policy" {
  name   = "${var.namespace}-ap-policy"
  policy = data.aws_iam_policy_document.ap_access.json
}

data "aws_iam_policy_document" "ap_access" {
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
      "arn:aws:s3:::moj-reg-prod/landing/hmpps-adjustments-api-prod/*",
      "arn:aws:s3:::moj-reg-prod/landing/hmpps-adjustments-api-prod/"
    ]
  }
}

resource "random_id" "id" {
  byte_length = 16
}

resource "aws_iam_user" "user" {
  name = "ap-s3-bucket-user-${random_id.id.hex}"
  path = "/system/ap-s3-bucket-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy" "policy" {
  name   = "${var.namespace}-ap-s3-snapshots"
  policy = data.aws_iam_policy_document.ap_access.json
  user   = aws_iam_user.user.name
}

resource "kubernetes_secret" "ap_aws_secret" {
  metadata {
    name      = "analytical-platform-reporting-s3-bucket"
    namespace = var.namespace
  }

  data = {
    destination_bucket = "s3://moj-reg-prod/landing/hmpps-adjustments-api-prod/"
    user_arn           = aws_iam_user.user.arn
    access_key_id      = aws_iam_access_key.user.id
    secret_access_key  = aws_iam_access_key.user.secret
  }
}

resource "kubernetes_secret" "ap_irsa" {
  metadata {
    name      = "to-ap-s3-irsa"
    namespace = var.namespace
  }

  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
  }
}
