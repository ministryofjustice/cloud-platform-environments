# IRSA policy for S3 access read only permissions
data "aws_iam_policy_document" "s3_av_policy" {
  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
    ]

    resources = [
      module.s3_bucket.bucket_arn,
      "${module.s3_bucket.bucket_arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_av_policy" {
  name   = "${var.namespace}-s3-av-policy"
  policy = data.aws_iam_policy_document.s3_av_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

# Create IRSA role for S3 access with read only permissions
module "irsa_av" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "justice-gov-uk-dev-av"
  namespace            = var.namespace

  role_policy_arns = {
    s3_av = aws_iam_policy.s3_av_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
