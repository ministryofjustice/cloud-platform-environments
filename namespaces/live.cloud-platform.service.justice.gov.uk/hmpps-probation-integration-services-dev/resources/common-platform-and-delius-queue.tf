resource "aws_sns_topic_subscription" "common-platform-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.common-platform-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [] # TODO add event type filter e.g ["prison.case-note.published"]
  })
}

module "common-platform-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "common-platform-and-delius-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.common-platform-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "common-platform-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "common-platform-and-delius-queue-policy" {
  queue_url = module.common-platform-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "common-platform-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "common-platform-and-delius-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "common-platform-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "common-platform-and-delius-dlq-policy" {
  queue_url = module.common-platform-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "common-platform-and-delius-queue-secret" {
  metadata {
    name      = "common-platform-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.common-platform-and-delius-queue.sqs_name
  }
}

module "common-platform-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "common-platform-and-delius"
  role_policy_arns     = { sqs = module.common-platform-and-delius-queue.irsa_policy_arn }
}
