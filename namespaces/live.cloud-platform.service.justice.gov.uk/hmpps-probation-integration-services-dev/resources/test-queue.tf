resource "aws_sns_topic_subscription" "test-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.test-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [] # TODO add event type filter e.g ["prison.case-note.published"]
  })
}

module "test-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "test-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.test-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "test"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "test-queue-policy" {
  queue_url = module.test-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "test-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "test-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "test"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "test-dlq-policy" {
  queue_url = module.test-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "test-queue-secret" {
  metadata {
    name      = "test-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.test-queue.sqs_name
  }
}

module "test-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "test"
  role_policy_arns     = { sqs = module.test-queue.irsa_policy_arn }
}
