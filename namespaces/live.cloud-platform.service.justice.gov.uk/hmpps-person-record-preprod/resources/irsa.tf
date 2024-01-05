locals {
  # *** Placeholder for incoming SQS queues ***
  sqs_queues = {
  }
  # *** Placeholder for incoming SNS topics ***
  sns_topics = {
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}


module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = "person-record-service"
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = merge(
    local.sns_policies,
    local.sqs_policies,
    { rds = module.hmpps_person_record_rds.irsa_policy_arn },
    { sqs_cpr_cce = module.cpr_court_case_events_queue.irsa_policy_arn },
    { sqs_cpr_cce_dlq = module.cpr_court_case_events_dead_letter_queue.irsa_policy_arn },
    { sqs_cpr_delius_oe = module.cpr_delius_offender_events_queue.irsa_policy_arn },
    { sqs_cpr_delius_oe_dlq = module.cpr_delius_offender_events_dead_letter_queue.irsa_policy_arn }
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