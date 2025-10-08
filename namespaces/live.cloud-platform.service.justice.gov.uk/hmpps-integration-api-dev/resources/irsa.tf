# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  # The names of the queues used and the namespace which created them.
  sqs_queues = {
    "Digital-Prison-Services-dev-hmpps_audit_queue"                                 = "hmpps-audit-dev",
    "education-skills-work-employment-dev-hmpps_jobs_board_integration_queue"       = "hmpps-jobs-board-integration-dev",
    "book-a-prison-visit-dev-hmpps_prison_visits_write_events_queue"                = "visit-someone-in-prison-backend-svc-dev",
    "book-a-prison-visit-dev-hmpps_prison_visits_write_events_dlq"                  = "visit-someone-in-prison-backend-svc-dev",
    "locations-inside-prison-development-update_from_external_system_events_queue"  = "hmpps-locations-inside-prison-dev"
    "hmpps-farsight-reduce-re-offend-development-eawp_assessment_events_queue"      = "hmpps-education-and-work-plan-dev",
    "activities-and-appointments-dev-update_from_external_system_events_queue"      = "hmpps-activities-management-dev"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573" = "hmpps-domain-events-dev"
  }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-integration-api"
  role_policy_arns = merge(
    local.sqs_policies,
    local.sns_policies,
  )
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "hmpps-integration-event-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-integration-event"
  role_policy_arns = merge(
    {
      integration_api_domain_events_queue             = module.integration_api_domain_events_queue.irsa_policy_arn,
      integration_api_domain_events_dead_letter_queue = module.integration_api_domain_events_dead_letter_queue.irsa_policy_arn,
      hmpps-integration-events                        = module.integration_api_domain_events_queue.irsa_policy_arn,
      s3                                              = module.certificate_backup.irsa_policy_arn,
      truststore                                      = module.truststore_s3_bucket.irsa_policy_arn,
      secrets                                         = aws_iam_policy.secrets_manager_access.arn,
      event_topic                                     = module.hmpps-integration-events.irsa_policy_arn,
      mapps_queue                                     = module.event_mapps_queue.irsa_policy_arn,
      pnd_queue                                       = module.event_pnd_queue.irsa_policy_arn,
      test_client_queue                               = module.event_test_client_queue.irsa_policy_arn,
      plp_queue                                       = module.event_plp_queue.irsa_policy_arn,
      zkhan_queue                                     = module.event_zkhan_queue.irsa_policy_arn
    }

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

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "irsa-output"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}
