resource "aws_sns_topic_subscription" "prison-identifier-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.prison-identifier-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["prison-identifier-events.prisoner.updated"]
  })
}

module "prison-identifier-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "prison-identifier-and-delius-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prison-identifier-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "prison-identifier-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "prison-identifier-and-delius-queue-policy" {
  queue_url = module.prison-identifier-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "prison-identifier-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "prison-identifier-and-delius-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "prison-identifier-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "prison-identifier-and-delius-dlq-policy" {
  queue_url = module.prison-identifier-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "prison-identifier-and-delius-queue-secret" {
  metadata {
    name      = "prison-identifier-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.prison-identifier-and-delius-queue.sqs_name
  }
}

module "prison-identifier-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "prison-identifier-and-delius"
  role_policy_arns     = { sqs = module.prison-identifier-and-delius-queue.irsa_policy_arn }
}
