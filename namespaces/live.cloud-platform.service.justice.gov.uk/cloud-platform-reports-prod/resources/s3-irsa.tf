module "s3-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "hoodaw-${var.environment}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns     = {
    s3 = aws_iam_policy.allow-irsa-read.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_iam_policy" "allow-irsa-read" {
  name        = "cloud-platform-hoodaw-read-only"
  path        = "/cloud-platform/"
  policy      = data.aws_iam_policy_document.document.json
  description = "Policy for reading reports from cloud-platform-hoodaw-reports"
}
data "aws_iam_policy_document" "document" {
  statement {
    actions = [
      "s3:GetObject",
      "s3:ListBucket"
    ]
    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*",
    ]
  }
}

resource "kubernetes_secret" "s3-irsa" {
  metadata {
    name      = "hoodaw-readonly-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.s3-irsa.role_name
    serviceaccount = module.s3-irsa.service_account.name
  }
}