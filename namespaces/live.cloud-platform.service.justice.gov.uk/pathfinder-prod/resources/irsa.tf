locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-pathfinder_offender_events_queue"              = "offender-events-prod"
    "Digital-Prison-Services-prod-pathfinder_offender_events_queue_dl"           = "offender-events-prod"
    "Digital-Prison-Services-prod-pathfinder_probation_offender_events_queue"    = "offender-events-prod"
    "Digital-Prison-Services-prod-pathfinder_probation_offender_events_queue_dl" = "offender-events-prod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }

  sns_topics_api = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_policies_api = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_api : item.name => item.value }
  irsa_policies_api = merge(local.sqs_policies_api, {
    pathfinder_api_queue_for_domain_events                   = module.pathfinder_api_queue_for_domain_events.irsa_policy_arn
    pathfinder_api_queue_for_domain_events_dead_letter_queue = module.pathfinder_api_queue_for_domain_events_dead_letter_queue.irsa_policy_arn
    pathfinder_api_queue_for_probation_events                   = module.pathfinder_api_queue_for_probation_events.irsa_policy_arn
    pathfinder_api_queue_for_probation_events_dead_letter_queue = module.pathfinder_api_queue_for_probation_events_dead_letter_queue.irsa_policy_arn
  })
}

# IRSA for pathfinder deployment
module "irsa_pathfinder" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "pathfinder"
  role_policy_arns = merge(
    { "rds"      = module.dps_rds.irsa_policy_arn,
      "s3"       = module.pathfinder_document_s3_bucket.irsa_policy_arn,
      "s3-extra" = aws_iam_policy.irsa_additional_s3_policy.arn,
    "ap-s3-access" = aws_iam_policy.ap_policy.arn },
    local.sqs_policies
  )
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

# IRSA for pathfinder-api deployment
module "irsa_hmpps_pathfinder_api" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  namespace              = var.namespace
  eks_cluster_name       = var.eks_cluster_name
  service_account_name   = "pathfinder-api"
  role_policy_arns       = local.irsa_policies_api
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs_api" {
  for_each = local.sns_topics_api
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

resource "kubernetes_secret" "pathfinder_irsa" {
  metadata {
    name      = "pathfinder-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa_pathfinder.role_name
    serviceaccount = module.irsa_pathfinder.service_account.name
  }
}