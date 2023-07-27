module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace        = var.namespace
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "${var.namespace}-sa"
  role_policy_arns = {
    cross_irsa = aws_iam_policy.allow_s3_access_policy.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "allow_s3_access_policy" {
  # Provide list of permissions and target AWS account resources to allow access to
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl"
    ]
    resources = [
      "arn:aws:s3:::s3-bucket-output/*"
    ]
  }
}

resource "aws_iam_policy" "allow_s3_access_policy" {
  name   = "allow_s3_access_policy"
  policy = data.aws_iam_policy_document.allow_s3_access_policy.json

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    environment-name       = var.environment
    owner                  = var.team_name
    infrastructure-support = var.infrastructure_support
  }
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    rolearn        = module.irsa.role_arn
    serviceaccount = module.irsa.service_account.name
  }
}
