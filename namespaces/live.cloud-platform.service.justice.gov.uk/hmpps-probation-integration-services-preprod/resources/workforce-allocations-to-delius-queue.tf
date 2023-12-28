resource "aws_sns_topic_subscription" "workforce-allocations-to-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.workforce-allocations-to-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "person.community.manager.allocated",
      "event.manager.allocated",
      "requirement.manager.allocated",
    ]
  })
}

module "workforce-allocations-to-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "workforce-allocations-to-delius-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.workforce-allocations-to-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "workforce-allocations-to-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "workforce-allocations-to-delius-queue-policy" {
  queue_url = module.workforce-allocations-to-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "workforce-allocations-to-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "workforce-allocations-to-delius-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "workforce-allocations-to-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name # also used as queue name prefix
}

resource "aws_sqs_queue_policy" "workforce-allocations-to-delius-dlq-policy" {
  queue_url = module.workforce-allocations-to-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "workforce-allocations-to-delius-queue-secret" {
  metadata {
    name      = "workforce-allocations-to-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.workforce-allocations-to-delius-queue.sqs_name
  }
}

module "workforce-allocations-to-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "workforce-allocations-to-delius"
  role_policy_arns     = { sqs = module.workforce-allocations-to-delius-queue.irsa_policy_arn }
}
