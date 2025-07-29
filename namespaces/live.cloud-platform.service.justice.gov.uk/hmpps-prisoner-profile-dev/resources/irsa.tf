
# Add the names of the SQS which the app needs permissions to access.
# The value of each item should be the namespace where the SQS was created.
# This information is used to collect the IAM policies which are used by the IRSA module.
data "kubernetes_secret" "injected_audit_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }
}

data "aws_ssm_parameter" "audit_irsa_policy_arn" {
  name = "/hmpps-audit-dev/sqs/${data.kubernetes_secret.injected_audit_secret.data.sqs_queue_name}/irsa-policy-arn"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"

  eks_cluster_name     = var.eks_cluster_name
  namespace            = var.namespace
  service_account_name = "hmpps-prisoner-profile"
  {
    audit = data.aws_ssm_parameter.audit_irsa_policy_arn.value
  }
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}


