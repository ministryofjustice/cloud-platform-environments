locals {
  sqs_queues = {
    "Digital-Prison-Services-prod-hmpps_audit_queue"                       = "hmpps-audit-prod",
    "Digital-Prison-Services-prod-activities_domain_events_queue"          = "hmpps-domain-events-prod",
    "Digital-Prison-Services-prod-activities_domain_events_dl"             = "hmpps-domain-events-prod",
    "Digital-Prison-Services-prod-hmpps_workload_offender_events_queue"    = "offender-events-prod"
    "Digital-Prison-Services-prod-hmpps_workload_offender_events_queue_dl" = "offender-events-prod",
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

data "aws_iam_policy_document" "combined_local_sqs" {
  version = "2012-10-17"
  statement {
    sid     = "hmppsWorkloadSqs"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.hmpps_reductions_completed_queue.sqs_arn,
      module.hmpps_reductions_completed_dead_letter_queue.sqs_arn,
      module.hmpps_extract_placed_queue.sqs_arn,
      module.hmpps_extract_placed_dead_letter_queue.sqs_arn,
      module.hmpps_workload_person_on_probation_queue.sqs_arn,
      module.hmpps_workload_person_on_probation_dead_letter_queue.sqs_arn,
      module.hmpps_workload_prisoner_queue.sqs_arn,
      module.hmpps_workload_prisoner_dead_letter_queue.sqs_arn,
      module.hmpps_workload_staff_queue.sqs_arn,
      module.hmpps_workload_staff_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_local_sqs" {
  policy = data.aws_iam_policy_document.combined_local_sqs.json
  tags   = local.default_tags
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  #
  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-workload"
  namespace            = var.namespace
  role_policy_arns = merge(
    local.sns_policies,
    local.sqs_policies,
    { combined_local_sqs = aws_iam_policy.combined_local_sqs.arn },
    { dashboard_s3 = module.hmpps-workload-prod-s3-dashboard-bucket.irsa_policy_arn },
    { extract_s3 = module.hmpps-workload-prod-s3-extract-bucket.irsa_policy_arn },
    { rds_history = module.rds-history.irsa_policy_arn },
    { rds_live = module.rds-live.irsa_policy_arn },
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.0" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}

data "aws_ssm_parameter" "irsa_policy_arns_sqs" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
data "aws_ssm_parameter" "irsa_policy_arns_sns" {
  for_each = local.sns_topics
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}