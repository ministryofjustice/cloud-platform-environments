resource "aws_sns_topic_subscription" "supervision-packages-api-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.supervision-packages-api-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["TBC"] # TODO add event types for triggering supervision package assignment
  })
}

module "supervision-packages-api-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name = "supervision-packages-api-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.supervision-packages-api-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "supervision-packages-api"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "supervision-packages-api-queue-policy" {
  queue_url = module.supervision-packages-api-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "supervision-packages-api-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "supervision-packages-api-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "supervision-packages-api"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "supervision-packages-api-dlq-policy" {
  queue_url = module.supervision-packages-api-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "supervision-packages-api-queue-secret" {
  metadata {
    name      = "supervision-packages-api-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.supervision-packages-api-queue.sqs_name
  }
}

module "supervision-packages-api-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "supervision-packages-api"
  role_policy_arns     = { sqs = module.supervision-packages-api-queue.irsa_policy_arn }
}
