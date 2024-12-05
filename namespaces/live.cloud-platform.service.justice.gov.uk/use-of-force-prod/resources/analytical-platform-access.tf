module "ap_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=1.1.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  role_policy_arns = [aws_iam_policy.ap_policy.arn]
  service_account  = "${var.namespace}-to-ap-s3"
}

resource "aws_iam_policy" "ap_policy" {
  name   = "${var.namespace}-ap-policy"
  policy = data.aws_iam_policy_document.uof_ap_access.json
}

data "aws_iam_policy_document" "uof_ap_access" {
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
      "arn:aws:s3:::moj-reg-prod/landing/hmpps-use-of-force-prod/*",
      "arn:aws:s3:::moj-reg-prod/landing/hmpps-use-of-force-prod/"
    ]
  }
}

resource "kubernetes_secret" "ap_irsa" {
  metadata {
    name      = "uof-to-ap-s3-irsa"
    namespace = var.namespace
  }

  data = {
    role           = module.ap_irsa.aws_iam_role_name
    serviceaccount = module.ap_irsa.service_account_name.name
  }
}
