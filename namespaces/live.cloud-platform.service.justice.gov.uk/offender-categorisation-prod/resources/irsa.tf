locals {
  sqs_queues_oc = {
    "Digital-Prison-Services-prod-offender_categorisation_ui_events_queue_dl" = "offender-events-prod"
    "Digital-Prison-Services-prod-offender_categorisation_ui_events_queue"    = "offender-events-prod"
  }
  sqs_queues_rp = {
    "Digital-Prison-Services-prod-offender_categorisation_events_queue"    = "offender-events-prod"
    "Digital-Prison-Services-prod-offender_categorisation_events_queue_dl" = "offender-events-prod"
  }
  sqs_policies_oc = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_oc : item.name => item.value }
  sqs_policies_rp = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_rp : item.name => item.value }
}

# IRSA for offender-categorisation deployment
module "irsa_offender_categorisation" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "offender-categorisation"
  role_policy_arns = merge(
    { "rds"                  = module.dps_rds.irsa_policy_arn,
      "risk_profiler_change" = module.risk_profiler_change.irsa_policy_arn,
    "risk_profiler_change_dl" = module.risk_profiler_change_dead_letter_queue.irsa_policy_arn },
    local.sqs_policies_oc
  )
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

# IRSA for offender-risk-profiler deployment
module "irsa_offender_risk_profiler" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "offender-risk-profiler"
  role_policy_arns = merge(
    { "s3"                   = module.risk_profiler_s3_bucket.irsa_policy_arn,
      "risk_profiler_change" = module.risk_profiler_change.irsa_policy_arn,
    "risk_profiler_change_dl" = module.risk_profiler_change_dead_letter_queue.irsa_policy_arn },
    local.sqs_policies_rp
  )
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs_oc" {
  for_each = local.sqs_queues_oc
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs_rp" {
  for_each = local.sqs_queues_rp
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}