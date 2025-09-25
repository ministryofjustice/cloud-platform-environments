# Add the names of the SQS/SNS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS/SNS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod",
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }

  rds_policies = {
    visit_scheduler_rds              = module.visit_scheduler_pg_rds.irsa_policy_arn,
    prison_visit_booker_reg_rds      = module.prison_visit_booker_reg_rds.irsa_policy_arn,
    visit_allocation_rds             = module.visit_allocation_rds.irsa_policy_arn
  }

  all_policies = merge(
    local.rds_policies,
    local.sns_policies
  )
}

data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}

data "aws_iam_policy_document" "combined_sqs_policies" {
    version = "2012-10-17"
  statement {
    sid       = "CombinedSqsPolicies"
    effect    = "Allow"
    actions   = ["sqs:*"]
    resources = [
      module.hmpps_prison_visits_event_queue.irsa_policy_arn,
      module.hmpps_prison_visits_event_dead_letter_queue.irsa_policy_arn,
      module.hmpps_prison_visits_notification_alerts_queue.irsa_policy_arn,
      module.hmpps_prison_visits_notification_alerts_dead_letter_queue.irsa_policy_arn,
      module.hmpps_prison_visits_allocation_events_queue.irsa_policy_arn,
      module.hmpps_prison_visits_allocation_events_dead_letter_queue.irsa_policy_arn,
      module.hmpps_prison_visits_allocation_processing_job_queue.irsa_policy_arn,
      module.hmpps_prison_visits_allocation_processing_job_dead_letter_queue.irsa_policy_arn,
      module.hmpps_prison_visits_allocation_prisoner_retry_queue.irsa_policy_arn,
      module.hmpps_prison_visits_allocation_prisoner_retry_dead_letter_queue.irsa_policy_arn,
      module.hmpps_prison_visits_write_events_queue.irsa_policy_arn,
      module.hmpps_prison_visits_write_events_dead_letter_queue.irsa_policy_arn
    ]
  }
}

resource "aws_iam_policy" "combined_sqs_policies" {
  name   = "${var.application}-combined-sqs-policies"
  policy = data.aws_iam_policy_document.combined_sqs_policies.json
}

module "irsa" {
  source               = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  namespace            = var.namespace
  service_account_name = var.application
  role_policy_arns     = ["local.all_policies", aws_iam_policy.combined_sqs_policies.arn]

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
  eks_cluster_name       = var.eks_cluster_name
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}
