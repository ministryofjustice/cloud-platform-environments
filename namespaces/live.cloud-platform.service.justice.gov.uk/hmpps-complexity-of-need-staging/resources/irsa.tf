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
    domain_events_sns = data.aws_ssm_parameter.irsa_policy_arn_sns_domain_events.value
  }

  # Tags
  business_unit          = "HMPPS"
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

data "aws_ssm_parameter" "irsa_policy_arn_sns_domain_events" {
  name = "/hmpps-domain-events-dev/sns/cloud-platform-Digital-Prison-Services-e29fb030a51b3576dd645aa5e460e573/irsa-policy-arn"
}
