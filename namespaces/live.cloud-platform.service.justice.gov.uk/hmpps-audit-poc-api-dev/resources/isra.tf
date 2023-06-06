# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
locals {
  sqs_queues = {
    "hmpps_audit_queue"    = "hmpps-audit-dev",
    "hmpps_audit_dead_letter_queue" = "hmpps-audit-dev"
  }
  sqs_policies      = [for item in data.aws_ssm_parameter.irsa_policy_arns : item.value]
}

module "app-irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name = var.eks_cluster_name
  namespace        = var.namespace
  service_account  = "${var.application}-${var.environment-name}"
  role_policy_arns = [for item in data.aws_ssm_parameter.irsa_policy_arns : item.value]
}

data "aws_ssm_parameter" "irsa_policy_arns" {
  for_each = local.sqs_queues
  name     = "/${each.value}/sqs/${each.key}/irsa-policy-arn"
}
