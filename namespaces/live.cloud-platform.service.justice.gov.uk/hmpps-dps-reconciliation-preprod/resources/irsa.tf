data "aws_iam_policy_document" "combined_local_sqs" {
  version = "2012-10-17"
  statement {
    sid     = "hmppsDpsReconciliationSqs"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.hmpps_dps_reconciliation_queue.sqs_arn,
      module.hmpps_dps_reconciliation_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_local_sqs" {
  policy = data.aws_iam_policy_document.combined_local_sqs.json
  tags   = local.default_tags
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name
  service_account_name = "hmpps-dps-reconciliation"
  role_policy_arns = { combined_local_sqs = aws_iam_policy.combined_local_sqs.arn }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
