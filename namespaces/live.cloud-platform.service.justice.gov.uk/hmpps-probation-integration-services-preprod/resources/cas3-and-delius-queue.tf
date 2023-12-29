resource "aws_sns_topic_subscription" "cas3-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.cas3-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "accommodation.cas3.referral.submitted",
      "accommodation.cas3.booking.provisionally-made",
      "accommodation.cas3.booking.cancelled",
      "accommodation.cas3.person.arrived",
      "accommodation.cas3.booking.confirmed",
      "accommodation.cas3.person.departed",
      "accommodation.cas3.person.arrived.updated",
      "accommodation.cas3.booking.cancelled.updated",
      "accommodation.cas3.person.departed.updated"
    ]
  })
}

module "cas3-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "cas3-and-delius-queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.cas3-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  application            = "cas3-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "cas3-and-delius-queue-policy" {
  queue_url = module.cas3-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "cas3-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"
  # Queue configuration
  sqs_name                  = "cas3-and-delius-dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  # Tags
  application            = "cas3-and-delius"
  business_unit          = var.business_unit
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name
}

resource "aws_sqs_queue_policy" "cas3-and-delius-dlq-policy" {
  queue_url = module.cas3-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "cas3-and-delius-queue-secret" {
  metadata {
    name      = "cas3-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.cas3-and-delius-queue.sqs_name
  }
}

module "cas3-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "cas3-and-delius"
  role_policy_arns     = { sqs = module.cas3-and-delius-queue.irsa_policy_arn }
}
