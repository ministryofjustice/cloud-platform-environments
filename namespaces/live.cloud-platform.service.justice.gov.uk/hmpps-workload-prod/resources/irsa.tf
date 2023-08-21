locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_audit_queue" = "hmpps-audit-prod",
    "Digital-Prison-Services-prod-activities_domain_events_queue" = "hmpps-domain-events-prod",
    "Digital-Prison-Services-prod-activities_domain_events_dl" = "hmpps-domain-events-prod"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
#
  eks_cluster_name      = var.eks_cluster_name
  service_account_name  = "hmpps-workload"
  namespace             = var.namespace
  role_policy_arns      = merge(
    local.sns_policies,
    local.sqs_policies,
    { domain_sns    = module.hmpps_reductions_completed_queue.irsa_policy_arn },
    { domain_dlq    = module.hmpps_reductions_completed_dead_letter_queue.irsa_policy_arn },
    { extract_sqs   = module.hmpps_extract_placed_queue.irsa_policy_arn },
    { extract_dlq   = module.hmpps_extract_placed_dead_letter_queue.irsa_policy_arn },
    { pop_sqs       = module.hmpps_workload_person_on_probation_queue.irsa_policy_arn },
    { pop_dlq       = module.hmpps_workload_person_on_probation_dead_letter_queue.irsa_policy_arn },
    { prisoner_sqs  = module.hmpps_workload_prisoner_queue.irsa_policy_arn },
    { prisoner_dlq  = module.hmpps_workload_prisoner_dead_letter_queue.irsa_policy_arn },
    { staff_sqs     = module.hmpps_workload_staff_queue.irsa_policy_arn },
    { staff_dlq     = module.hmpps_workload_staff_dead_letter_queue.irsa_policy_arn },
    { dashboard_s3  = module.hmpps-workload-prod-s3-dashboard-bucket.irsa_policy_arn },
    { extract_s3    = module.hmpps-workload-prod-s3-extract-bucket.irsa_policy_arn },
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}