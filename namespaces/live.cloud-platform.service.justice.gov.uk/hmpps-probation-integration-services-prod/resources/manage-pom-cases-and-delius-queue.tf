resource "aws_sns_topic_subscription" "manage-pom-cases-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.manage-pom-cases-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "offender-management.handover.changed"
    ]
  })
}

module "manage-pom-cases-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "manage-pom-cases-and-delius"
  sqs_name    = "manage-pom-cases-and-delius-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.manage-pom-cases-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "manage-pom-cases-and-delius-queue-policy" {
  queue_url = module.manage-pom-cases-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "manage-pom-cases-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "manage-pom-cases-and-delius"
  sqs_name    = "manage-pom-cases-and-delius-dlq"
}

resource "aws_sqs_queue_policy" "manage-pom-cases-and-delius-dlq-policy" {
  queue_url = module.manage-pom-cases-and-delius-dlq.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "manage-pom-cases-and-delius-queue-secret" {
  metadata {
    name      = "manage-pom-cases-and-delius-queue"
    namespace = var.namespace
  }
  data = {
    QUEUE_NAME            = module.manage-pom-cases-and-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.manage-pom-cases-and-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.manage-pom-cases-and-delius-queue.secret_access_key
  }
}