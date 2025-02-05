resource "aws_sns_topic_subscription" "hmpps-tier-events-queue-subscription" {
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps-tier-events-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "assessment.summary.produced",
      "enforcement.breach.raised",
      "enforcement.breach.concluded",
      "enforcement.recall.raised",
      "enforcement.recall.concluded",
      "probation-case.engagement.created",
      "probation-case.deleted.gdpr",
      "probation-case.merge.completed",
      "probation-case.unmerge.completed",
      "probation-case.registration.added",
      "probation-case.registration.updated",
      "probation-case.registration.deleted",
      "probation-case.registration.deregistered",
      "probation-case.requirement.created",
      "probation-case.requirement.deleted",
      "probation-case.requirement.terminated",
      "probation-case.requirement.unterminated"
    ]
  })
}

module "hmpps-tier-events-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name = "hmpps-tier-events-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps-tier-events-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

data "aws_iam_policy_document" "sns_to_sqs" {
  statement {
    sid     = "DomainEventsToQueue"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      variable = "aws:SourceArn"
      test     = "ArnEquals"
      values   = [data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value]
    }
    resources = ["*"]
  }
}

resource "aws_sqs_queue_policy" "hmpps-tier-events-queue-policy" {
  queue_url = module.hmpps-tier-events-queue.sqs_id
  policy    = data.aws_iam_policy_document.sns_to_sqs.json
}

module "hmpps-tier-events-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name                  = "hmpps-tier-events-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = var.application
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "kubernetes_secret" "hmpps-tier-events-queue-secret" {
  metadata {
    name      = "sqs-domain-events-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps-tier-events-queue.sqs_id
    sqs_queue_arn  = module.hmpps-tier-events-queue.sqs_arn
    sqs_queue_name = module.hmpps-tier-events-queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps-tier-events-dlq-secret" {
  metadata {
    name      = "sqs-domain-events-dl-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps-tier-events-dlq.sqs_id
    sqs_queue_arn  = module.hmpps-tier-events-dlq.sqs_arn
    sqs_queue_name = module.hmpps-tier-events-dlq.sqs_name
  }
}
