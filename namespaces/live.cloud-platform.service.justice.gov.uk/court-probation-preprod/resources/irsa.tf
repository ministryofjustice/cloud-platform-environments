locals {
  sqs_queues = {
    "Digital-Prison-Services-preprod-pic_probation_offender_events_queue"    = "offender-events-preprod"
    "Digital-Prison-Services-preprod-pic_probation_offender_events_queue_dl" = "offender-events-preprod"
  }
  sns_topics = {
    "cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd" = "hmpps-domain-events-preprod"
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  sns_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sns : item.name => item.value }
}


module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = var.application
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = merge(
    local.sns_policies,
    local.sqs_policies,
    { rds_ccs = module.court_case_service_rds.irsa_policy_arn },
    { rds_pss = module.pre_sentence_service_rds.irsa_policy_arn },
    { s3_cpg = module.crime-portal-gateway-s3-bucket.irsa_policy_arn },
    { s3_pt = module.perf-test-data-s3-bucket.irsa_policy_arn },
    { sns_cce = module.court-case-events.irsa_policy_arn },
    { sqs_cpg = module.crime-portal-gateway-queue.irsa_policy_arn },
    { sqs_cpg_dlq = module.crime-portal-gateway-dead-letter-queue.irsa_policy_arn },
    { sqs_ccm = module.court-case-matcher-queue.irsa_policy_arn },
    { sqs_ccm_dlq = module.court-case-matcher-dead-letter-queue.irsa_policy_arn },
    { sqs_ccs = module.pic_new_offender_events_queue.irsa_policy_arn },
    { sqs_ccs_dlq = module.pic_new_offender_events_dead_letter_queue.irsa_policy_arn },
    { elasticache = module.pac_elasticache_redis.irsa_policy_arn }
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
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