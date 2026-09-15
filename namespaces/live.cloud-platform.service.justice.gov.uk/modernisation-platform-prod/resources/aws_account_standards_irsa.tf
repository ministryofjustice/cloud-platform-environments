module "mp_aws_account_standards_irsa_scanner" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "aws-account-standards"
  role_policy_arns = {
    assume_aws_account_standards_scanner_role = aws_iam_policy.mp_assume_aws_account_standards_scanner_role.arn
  }
  business_unit          = var.business_unit
  application            = "aws-account-standards"
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
data "aws_iam_policy_document" "mp_assume_aws_account_standards_role" {
  statement {
    sid     = "AllowAssumeMpAwsAccountStandardsScannerRole"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    resources = [
      "arn:aws:iam::*:role/mp-aws-account-standards-scanner-role"
    ]
  }
}

resource "aws_iam_policy" "mp_assume_aws_account_standards_scanner_role" {
  name        = "mp-assume-aws-account-standards-scanner-role"
  description = "Allows the aws-account-standards workload (Kubernetes namespace ${var.namespace}) to assume the mp-aws-account-standards-scanner-role role in target AWS accounts."
  policy      = data.aws_iam_policy_document.mp_assume_aws_account_standards_role.json
}
