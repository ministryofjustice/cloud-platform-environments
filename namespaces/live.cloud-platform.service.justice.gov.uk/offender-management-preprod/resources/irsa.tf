module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  # EKS configuration
  eks_cluster_name = var.eks_cluster_name

  # IRSA configuration
  service_account_name = var.application
  namespace            = var.namespace # this is also used as a tag

  # Attach the appropriate policies using a key => value map. If you're using Cloud Platform provided modules (e.g. SNS,
  # S3), these provide an output called `irsa_policy_arn` that can be used.
  role_policy_arns = {
    s3                    = module.s3_bucket.irsa_policy_arn
    domain_events_sqs     = module.domain_events_sqs_queue.irsa_policy_arn
    domain_events_sqs_dlq = module.domain_events_sqs_dlq.irsa_policy_arn
    domain_events_sns     = data.aws_ssm_parameter.irsa_policy_arn_sns_domain_events.value
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arn_sns_domain_events" {
  name = "/hmpps-domain-events-preprod/sns/cloud-platform-Digital-Prison-Services-15b2b4a6af7714848baeaf5f41c85fcd/irsa-policy-arn"
}

module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0"

  namespace            = var.namespace
  service_account_name = module.irsa.service_account.name
}
