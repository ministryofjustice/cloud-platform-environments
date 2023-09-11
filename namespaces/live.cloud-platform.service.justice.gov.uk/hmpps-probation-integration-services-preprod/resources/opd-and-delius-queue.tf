resource "aws_sns_topic_subscription" "opd-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.opd-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = ["opd.assessment"]
  })
}

module "opd-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "opd-and-delius"
  sqs_name    = "opd-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.opd-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "opd-and-delius-queue-policy" {
  queue_url = module.opd-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "opd-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "opd-and-delius"
  sqs_name    = "opd-and-delius-dlq"
}

resource "aws_sqs_queue_policy" "opd-and-delius-dlq-policy" {
  queue_url = module.opd-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "opd-and-delius-queue-secret" {
  metadata {
    name      = "opd-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME = module.opd-and-delius-queue.sqs_name
  }
}

module "service_account" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  application            = var.application
  business_unit          = var.business_unit
  eks_cluster_name       = var.eks_cluster_name
  environment_name       = var.environment_name
  infrastructure_support = var.infrastructure_support
  is_production          = var.is_production
  namespace              = var.namespace
  team_name              = var.team_name

  service_account_name = "opd-and-delius"
  role_policy_arns     = { sqs = module.opd-and-delius-queue.irsa_policy_arn }
}
