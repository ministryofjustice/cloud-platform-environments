module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-laa-landing-page-${var.environment}"
  namespace            = var.namespace
  
  role_policy_arns = {
    sqs = data.aws_ssm_parameter.sqs_policy_arn.value
    rds = module.rds.irsa_policy_arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "irsa_temp" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-laa-landing-page-${var.environment}-temp"
  namespace            = var.namespace
  
  role_policy_arns = {
    sqs = data.aws_ssm_parameter.sqs_policy_arn.value
    rds = module.rds_temp.irsa_policy_arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_iam_policy_document" "rds_backup_check_assume_role_policy" {
  statement {
    sid       = "DescribeRDSnapshots"
    effect    = "Allow"
    actions   = ["rds:DescribeDBSnapshots"]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rds_backup_check_policy" {
  name        = "${var.namespace}-rds-backup-check-policy"
  description = "Read-only permission for the rds-backup-check k8s cronjob to list DB snapshots and check their age"
  policy      = data.aws_iam_policy_document.rds_backup_check_assume_role_policy.json
}

module "irsa_rds_backup_check"{
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "irsa-laa-landing-page-${var.environment}-rds-backup-check"
  namespace            = var.namespace
  
  role_policy_arns = {
    rds_backup_check = aws_iam_policy.rds_backup_check_policy.arn
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
