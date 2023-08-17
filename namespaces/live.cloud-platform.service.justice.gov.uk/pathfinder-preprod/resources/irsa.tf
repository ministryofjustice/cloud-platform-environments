locals {
  sqs_queues = {
    "Digital-Prison-Services-preprod-pathfinder_offender_events_queue"              = "offender-events-preprod"
    "Digital-Prison-Services-preprod-pathfinder_offender_events_queue_dl"           = "offender-events-preprod"
    "Digital-Prison-Services-preprod-pathfinder_probation_offender_events_queue"    = "offender-events-preprod"
    "Digital-Prison-Services-preprod-pathfinder_probation_offender_events_queue_dl" = "offender-events-preprod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
}

# IRSA for pathfinder deployment
module "irsa_pathfinder" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  namespace            = var.namespace
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "pathfinder"
  role_policy_arns = merge(
    { "s3" = module.pathfinder_document_s3_bucket.irsa_policy_arn,
    "s3-extra" = aws_iam_policy.irsa_additional_s3_policy.arn },
    local.sqs_policies
  )
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
