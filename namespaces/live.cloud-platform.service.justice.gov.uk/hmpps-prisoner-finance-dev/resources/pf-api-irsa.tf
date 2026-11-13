
locals {
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }

  pf_api_irsa_policies = merge(local.sns_policies, {
    prisoner_finance_queue_for_domain_events_pf_api                   = module.prisoner_finance_queue_for_domain_events_pf_api.irsa_policy_arn
    prisoner_finance_queue_for_domain_events_dead_letter_queue_pf_api = module.prisoner_finance_queue_for_domain_events_dead_letter_queue_pf_api.irsa_policy_arn
  })
  prisoner_finance_api_irsa_policies = {
    rds = module.prisoner_finance_api_rds.irsa_policy_arn
  }
}


module "hmpps_prisoner_finance_api_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = var.service_account_name_api
  role_policy_arns     = local.pf_api_irsa_policies
  # Tags
  business_unit          = var.business_unit
  application            = var.prisoner_finance_application_name
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}