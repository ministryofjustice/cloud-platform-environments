locals {
  sqs_queues_oc = {
    "Digital-Prison-Services-prod-offender_categorisation_ui_events_queue_dl" = "offender-events-prod"
    "Digital-Prison-Services-prod-offender_categorisation_ui_events_queue"    = "offender-events-prod"
  }
  sqs_queues_rp = {
    "Digital-Prison-Services-prod-offender_categorisation_events_queue"    = "offender-events-prod"
    "Digital-Prison-Services-prod-offender_categorisation_events_queue_dl" = "offender-events-prod"
  }
  sns_topics_api = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_policies_oc = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_oc : item.name => item.value }
  sqs_policies_rp = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_rp : item.name => item.value }
  sqs_policies_api = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_api : item.name => item.value }
  irsa_policies_api = merge(local.sqs_policies_api, {
    offender_categorisation_api_queue_for_domain_events                   = module.offender_categorisation_api_queue_for_domain_events.irsa_policy_arn
    offender_categorisation_api_queue_for_domain_events_dead_letter_queue = module.offender_categorisation_api_queue_for_domain_events_dead_letter_queue.irsa_policy_arn
  })
}

# IRSA for offender-categorisation deployment
module "irsa_offender_categorisation" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
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
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
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

# IRSA for hmpps-offender-categorisation-api deployment
module "irsa_hmpps_offender_categorisation_api" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  namespace              = var.namespace
  eks_cluster_name       = var.eks_cluster_name
  service_account_name   = "hmpps-offender-categorisation-api"
  role_policy_arns = merge(
     { "s3" = module.risk_profiler_s3_bucket.irsa_policy_arn },
     local.irsa_policies_api
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

data "aws_ssm_parameter" "irsa_policy_arns_sqs_api" {
  for_each = local.sns_topics_api
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}