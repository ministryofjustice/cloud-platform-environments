resource "aws_sns_topic_subscription" "approved-premises-and-delius-queue-subscription" {
  topic_arn = data.aws_sns_topic.hmpps-domain-events.arn
  protocol  = "sqs"
  endpoint  = module.approved-premises-and-delius-queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "approved-premises.application.submitted",
      "approved-premises.application.assessed",
      "approved-premises.booking.made",
      "approved-premises.person.arrived",
      "approved-premises.person.not-arrived",
      "approved-premises.person.departed",
    ]
  })
}

module "approved-premises-and-delius-queue" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "approved-premises-and-delius-queue"
  sqs_name    = "approved-premises-and-delius-queue-queue"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.approved-premises-and-delius-dlq.sqs_arn
    maxReceiveCount     = 3
  })
}

resource "aws_sqs_queue_policy" "approved-premises-and-delius-queue-policy" {
  queue_url = module.approved-premises-and-delius-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

module "approved-premises-and-delius-dlq" {
  source                 = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"
  namespace              = var.namespace
  team_name              = var.team_name
  environment-name       = var.environment_name
  infrastructure-support = var.infrastructure_support

  application = "approved-premises-and-delius"
  sqs_name    = "approved-premises-and-delius-dlq"
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
    QUEUE_NAME            = module.approved-premises-and-delius-queue.sqs_name
    AWS_ACCESS_KEY_ID     = module.approved-premises-and-delius-queue.access_key_id
    AWS_SECRET_ACCESS_KEY = module.approved-premises-and-delius-queue.secret_access_key
  }
}
