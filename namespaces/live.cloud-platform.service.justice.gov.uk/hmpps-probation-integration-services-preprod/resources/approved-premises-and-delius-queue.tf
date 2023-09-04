resource "aws_sns_topic_subscription" "approved-premises-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.approved-premises-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "approved-premises.application.submitted",
      "approved-premises.application.assessed",
      "approved-premises.application.withdrawn",
      "approved-premises.booking.made",
      "approved-premises.booking.cancelled",
      "approved-premises.booking.changed",
    ]
  })
}

module "approved-premises-and-delius-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "approved-premises-and-delius-queue-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.approved-premises-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = "approved-premises-and-delius-queue"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "approved-premises-and-delius-queue-policy" {
  queue_url = module.approved-premises-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "approved-premises-and-delius-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name = "approved-premises-and-delius-dlq"

  # Tags
  business_unit          = var.business_unit
  application            = "approved-premises-and-delius"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "approved-premises-and-delius-dlq-policy" {
  queue_url = module.approved-premises-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "approved-premises-and-delius-queue-secret" {
  metadata {
    name      = "approved-premises-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.approved-premises-and-delius-queue.sqs_name
  }
}

module "approved-premises-and-delius-service-account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "approved-premises-and-delius"
  role_policy_arns     = { sqs = module.approved-premises-and-delius-queue.irsa_policy_arn }
}
