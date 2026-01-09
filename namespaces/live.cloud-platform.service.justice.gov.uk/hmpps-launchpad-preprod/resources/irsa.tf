# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "Digital-Prison-Services-preprod-hmpps_prisoner_audit_queue" = "hmpps-audit-preprod",
  }
  sqs_policies = { for item in data.aws_ssm_parameter.irsa_policy_arns_sqs : item.name => item.value }
  rds_policies = { rds = module.rds.irsa_policy_arn }
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"

  eks_cluster_name       = var.eks_cluster_name
  namespace              = var.namespace
  service_account_name   = "hmpps-launchpad-home-ui"
  role_policy_arns       = merge(local.sqs_policies, local.rds_policies)
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

# set up the service pod
module "service_pod" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-service-pod?ref=1.2.0" # use the latest release
  # Configuration
  namespace            = var.namespace
  service_account_name = module.irsa.service_account_name # this uses the service account name from the irsa module
}