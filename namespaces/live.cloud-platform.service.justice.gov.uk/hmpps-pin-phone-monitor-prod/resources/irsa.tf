locals {
  sns_topics_api = {
    "cloud-platform-Digital-Prison-Services-97e6567cf80881a8a52290ff2c269b08" = "hmpps-domain-events-prod"
  }
  sqs_policies_api = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs_api : item.name => item.value }
  irsa_policies_api = merge(local.sqs_policies_api, {
      pcms_api_queue_for_domain_events                   = module.pcms_api_queue_for_domain_events.irsa_policy_arn
      pcms_api_queue_for_domain_events_dead_letter_queue = module.pcms_api_queue_for_domain_events_dead_letter_queue.irsa_policy_arn
    })
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = var.application
  namespace            = var.namespace # this is also used as a tag

  # Attach the approprate policies using a key => value map
  # If you're using Cloud Platform provided modules (e.g. SNS, S3), these
  # provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = merge(
    {
        rds        = module.rds_aurora.irsa_policy_arn
        s3         = aws_iam_policy.irsa_s3_policy.arn
        s3_sqs     = module.hmpps_pin_phone_monitor_s3_event_queue.irsa_policy_arn
        s3_sqs_dlq = module.hmpps_pin_phone_monitor_s3_event_dead_letter_queue.irsa_policy_arn
   },
    local.irsa_policies_api
  )

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support
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

data "aws_ssm_parameter" "irsa_policy_arns_sqs_api" {
  for_each = local.sns_topics_api
  name     = "/${each.value}/sns/${each.key}/irsa-policy-arn"
}