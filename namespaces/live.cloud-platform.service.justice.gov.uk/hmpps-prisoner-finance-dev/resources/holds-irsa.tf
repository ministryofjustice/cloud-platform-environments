locals {
  holds_irsa_policies = merge(local.sns_policies, {
    pf_queue_for_domain_events_holds_api                   = module.pf_queue_for_domain_events_holds_api.irsa_policy_arn
    pf_queue_for_domain_events_dead_letter_queue_holds_api = module.pf_queue_for_domain_events_dead_letter_queue_holds_api.irsa_policy_arn
    rds                                                    = module.holds_rds.irsa_policy_arn
  })
}

module "hmpps_prisoner_finance_holds_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.service_account_name_holds
  role_policy_arns     = local.holds_irsa_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.holds_application_name
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

