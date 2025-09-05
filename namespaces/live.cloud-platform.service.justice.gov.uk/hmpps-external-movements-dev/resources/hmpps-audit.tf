locals {
  audit_queue_name = "Digital-Prison-Services-${var.environment}-hmpps_audit_queue"
}

resource "kubernetes_secret" "hmpps_audit_queue_secret" {
  metadata {
    name      = "sqs-hmpps-audit-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_name = local.audit_queue_name
    sqs_queue_url  = "https://sqs.eu-west-2.amazonaws.com/754256621582/${local.audit_queue_name}"
  }
}

data "aws_ssm_parameter" "audit_irsa_policy_arn" {
  name = "/hmpps-audit-${var.environment}/sqs/${local.audit_queue_name}/irsa-policy-arn"
}


module "ui_irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0" # use the latest release

  eks_cluster_name     = var.eks_cluster_name
  service_account_name = "hmpps-external-movements-ui"
  namespace            = var.namespace
  role_policy_arns = {
    audit_queue         = data.aws_ssm_parameter.audit_irsa_policy_arn.value,
  }

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
