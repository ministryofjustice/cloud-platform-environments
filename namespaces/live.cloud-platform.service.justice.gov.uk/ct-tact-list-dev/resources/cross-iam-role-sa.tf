data "aws_iam_policy_document" "irsa" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetObject",
      "s3:GetObjectAcl",
    ]
    resources = [
      "arn:aws:s3:::mojap-counter-terrorism-exports",
    ]
  }
}

resource "aws_iam_policy" "irsa" {
  # NB: IAM policy name must be unique within Cloud Platform
  name        = "${var.namespace}-irsa"
  policy      = data.aws_iam_policy_document.irsa.json
  description = "Policy for testing cloud-platform-terraform-irsa"
}

module "irsa" {
  # always replace with latest version from Github
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "${var.team_name}-${var.environment}"
  namespace            = var.namespace # this is also used as a tag
  role_policy_arns = {
    # s3 = aws_iam_policy.policy.arn
    # s3 = module.s3.irsa_policy_arn
    irsa = aws_iam_policy.irsa.arn
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.team_name}-irsa"
    namespace = var.namespace
  }
  data = {
    role_name       = module.irsa.role_name
    role_arn        = module.irsa.role_arn
    service_account = module.irsa.service_account.name
  }
}
