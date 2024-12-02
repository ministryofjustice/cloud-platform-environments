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

# CPR SQS Policies
data "aws_iam_policy_document" "combined_cpr_sqs" {
  statement {
    sid       = "hmppsCprQueuePolicy"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.cpr_recluster_events_queue.sqs_arn,
      module.cpr_recluster_events_dead_letter_queue.sqs_arn
    ]
  }
}

resource "aws_iam_policy" "combined_cpr_sqs" {
  policy = data.aws_iam_policy_document.combined_cpr_sqs.json
  tags   = local.default_tags
}

# Court Case Events SQS Policies
data "aws_iam_policy_document" "combined_court_case_sqs" {
  statement {
    sid       = "hmppsCourtCasePolicy"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.cpr_court_case_events_queue.sqs_arn,
      module.cpr_court_cases_queue.sqs_arn,
      module.cpr_court_case_events_dead_letter_queue.sqs_arn,
      module.cpr_court_cases_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_court_case_sqs" {
  policy = data.aws_iam_policy_document.combined_court_case_sqs.json
  tags   = local.default_tags
}

# Delius SQS Policies
data "aws_iam_policy_document" "combined_delius_sqs" {
  statement {
    sid     = "hmppsDeliusQueuePolicy"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.cpr_delius_offender_events_queue.sqs_arn,
      module.cpr_delius_offender_events_dead_letter_queue.sqs_arn,
      module.cpr_delius_merge_events_queue.sqs_arn,
      module.cpr_delius_merge_events_dead_letter_queue.sqs_arn,
      module.cpr_delius_delete_events_queue.sqs_arn,
      module.cpr_delius_delete_events_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_delius_sqs" {
  policy = data.aws_iam_policy_document.combined_delius_sqs.json
  tags   = local.default_tags
}

# NOMIS SQS Policies
data "aws_iam_policy_document" "combined_nomis_sqs" {
  statement {
    sid       = "hmppsNomisQueuePolicy"
    effect  = "Allow"
    actions = ["sqs:*"]
    resources = [
      module.cpr_nomis_events_queue.sqs_arn,
      module.cpr_nomis_events_dead_letter_queue.sqs_arn,
      module.cpr_nomis_merge_events_queue.sqs_arn,
      module.cpr_nomis_merge_events_dead_letter_queue.sqs_arn,
    ]
  }
}

resource "aws_iam_policy" "combined_nomis_sqs" {
  policy = data.aws_iam_policy_document.combined_nomis_sqs.json
  tags   = local.default_tags
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
    { combined_court_case_sqs = aws_iam_policy.combined_court_case_sqs.arn },
    { combined_delius_sqs = aws_iam_policy.combined_delius_sqs.arn },
    { combined_nomis_sqs = aws_iam_policy.combined_nomis_sqs.arn },
    { combined_cpr_sqs = aws_iam_policy.combined_cpr_sqs.arn }
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

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.0.1" # use the latest release

  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name # this uses the service account name from the irsa module
}