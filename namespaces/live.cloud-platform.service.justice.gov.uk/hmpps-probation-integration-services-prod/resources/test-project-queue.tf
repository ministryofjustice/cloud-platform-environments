resource "aws_sns_topic_subscription" "test-project-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.test-project-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [] # TODO add event type filter e.g ["prison.case-note.published"]
  })
}

module "test-project-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "test-project-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.test-project-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "test-project"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "test-project-queue-policy" {
  queue_url = module.test-project-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "test-project-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "test-project-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "test-project"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "test-project-dlq-policy" {
  queue_url = module.test-project-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "test-project-queue-secret" {
  metadata {
    name      = "test-project-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.test-project-queue.sqs_name
  }
}

module "test-project-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "test-project"
  role_policy_arns     = { sqs = module.test-project-queue.irsa_policy_arn }
}
