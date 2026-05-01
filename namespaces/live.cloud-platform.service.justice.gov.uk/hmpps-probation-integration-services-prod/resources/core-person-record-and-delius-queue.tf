resource "aws_sns_topic_subscription" "core-person-record-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.core-person-record-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "core-person-record.probation.address.created",
      "core-person-record.probation.address.updated",
      "core-person-record.probation.address.deleted",
    ],
    eventSource = {
      "anything-but" = ["delius"]
    }
  })
}

module "core-person-record-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "core-person-record-and-delius-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.core-person-record-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "core-person-record-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "core-person-record-and-delius-queue-policy" {
  queue_url = module.core-person-record-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "core-person-record-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "core-person-record-and-delius-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "core-person-record-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "core-person-record-and-delius-dlq-policy" {
  queue_url = module.core-person-record-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "core-person-record-and-delius-queue-secret" {
  metadata {
    name      = "core-person-record-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.core-person-record-and-delius-queue.sqs_name
  }
}

module "core-person-record-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "core-person-record-and-delius"
  role_policy_arns     = { sqs = module.core-person-record-and-delius-queue.irsa_policy_arn }
}
