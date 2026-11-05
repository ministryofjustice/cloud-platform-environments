module "producer_event_sqs_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name                  = "producer_event_sqs_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.producer_event_sqs_dlq.sqs_arn
    maxReceiveCount     = 5
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "producer_event_sqs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name        = "producer_event_sqs_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "producer_event_sqs_queue_secret" {
  metadata {
    name      = "producer-event-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.producer_event_sqs_queue.sqs_id
    sqs_queue_arn  = module.producer_event_sqs_queue.sqs_arn
    sqs_queue_name = module.producer_event_sqs_queue.sqs_name
  }
}

locals {
  sqs_queue_arns = {
    "${module.producer_event_sqs_queue.sqs_name}" = module.producer_event_sqs_queue.sqs_arn
    "${module.producer_event_sqs_dlq.sqs_name}"   = module.producer_event_sqs_dlq.sqs_arn
  }

  sqs_irsa_policies = {
    for k, v in aws_iam_policy.producer_event_sqs_irsa_policy : k => v.arn
  }
}

resource "aws_iam_policy" "producer_event_sqs_irsa_policy" {
  for_each = local.sqs_queue_arns

  name   = "${var.namespace}-${each.key}-queue"
  path   = "/cloud-platform/sqs/"
  policy = data.aws_iam_policy_document.sqs_irsa_policy[each.key].json

  tags = local.tags
}

resource "aws_ssm_parameter" "producer_event_sqs_irsa_policy_arn" {
  for_each = local.sqs_irsa_policies

  type  = "String"
  name  = "/${var.namespace}/sqs/${each.key}/irsa-policy-arn"
  value = each.value

  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}

resource "kubernetes_secret" "producer_event_sqs_dlq_secret" {
  metadata {
    name      = "producer-event-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.producer_event_sqs_dlq.sqs_id
    sqs_queue_arn  = module.producer_event_sqs_dlq.sqs_arn
    sqs_queue_name = module.producer_event_sqs_dlq.sqs_name
  }
}
