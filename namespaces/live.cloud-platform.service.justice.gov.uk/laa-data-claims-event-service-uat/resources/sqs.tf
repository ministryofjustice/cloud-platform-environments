data "aws_ssm_parameter" "sqs_queue_arn" {
  name = "/${var.producer_namespace}/sqs-queue-arn"
}

data "aws_ssm_parameter" "sqs_policy_arn" {
  name = "/${var.producer_namespace}/sqs-policy-arn"
}

module "irsa" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = var.eks_cluster_name
  service_account_name = "irsa-sqs-${var.namespace}"
  namespace            = var.namespace

  role_policy_arns = {
    sqs = data.aws_ssm_parameter.sqs_policy_arn.value
  }
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "irsa" {
  metadata {
    name      = "${var.namespace}-irsa"
    namespace = var.namespace
  }
  data = {
    role           = module.irsa.role_name
    serviceaccount = module.irsa.service_account.name
    rolearn        = module.irsa.role_arn
  }
}

resource "kubernetes_secret" "sqs_queue_arn" {
  metadata {
    name      = "${var.namespace}-sqs-arn"
    namespace = var.namespace
  }
  data = {
    arn = data.aws_ssm_parameter.sqs_queue_arn.value
  }
}