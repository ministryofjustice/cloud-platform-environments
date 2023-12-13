module "ap_irsa" {
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.namespace}-to-ap-s3"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    s3 = aws_iam_policy.ap_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
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
      "arn:aws:s3:::moj-reg-dev/landing/${var.namespace}/*",
      "arn:aws:s3:::moj-reg-dev/landing/${var.namespace}/"
    ]
  }
}

resource "kubernetes_secret" "ap_irsa" {
  metadata {
    name      = "analytical-platform-reporting-s3-irsa"
    namespace = var.namespace
  }

  data = {
    role               = module.ap_irsa.role_name
    serviceaccount     = module.ap_irsa.service_account.name
    rolearn            = module.ap_irsa.role_arn
    destination_bucket = "s3://moj-reg-dev/landing/${var.namespace}/"
  }
}
