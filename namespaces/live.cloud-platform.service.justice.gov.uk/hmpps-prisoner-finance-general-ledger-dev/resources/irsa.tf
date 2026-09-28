# Add the names of the SQS & SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  irsa_policies = {
    gl_calculcated_balance_queue     = module.prisoner_finance_general_ledger_queue_for_calculated_balances.irsa_policy_arn
    gl_calculcated_balance_queue_dlq = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.irsa_policy_arn
    rds                              = module.rds.irsa_policy_arn
  }
}

module "hmpps_prisoner_finance_gl_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.service_account_name
  role_policy_arns     = local.irsa_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

