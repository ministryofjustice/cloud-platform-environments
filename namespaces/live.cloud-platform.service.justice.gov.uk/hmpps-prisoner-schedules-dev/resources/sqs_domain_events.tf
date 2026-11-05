module "producer_event_sqs_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name                  = "producer_event_sqs_queue"
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.producer_event_sqs_dlq.sqs_arn
    maxReceiveCount     = 5
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "producer_event_sqs_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name        = "producer_event_sqs_dlq"
  message_retention_seconds = 7 * 24 * 3600 # 1 week

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "kubernetes_secret" "producer_event_sqs_queue_secret" {
  metadata {
    name      = "producer-event-queue"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.producer_event_sqs_queue.sqs_id
    sqs_queue_arn  = module.producer_event_sqs_queue.sqs_arn
    sqs_queue_name = module.producer_event_sqs_queue.sqs_name
  }
}


data "aws_iam_policy_document" "sqs_queue_policy_document" {
  policy_id = "${module.producer_event_sqs_queue.sqs_arn}/SQSDefaultPolicy"
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [module.producer_event_sqs_queue.sqs_arn]
    actions   = ["SQS:SendMessage"]
  }
}

resource "aws_sqs_queue_policy" "producer_event_sqs_queue_policy" {
  queue_url = module.producer_event_sqs_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_queue_policy_document.json
}

resource "kubernetes_secret" "producer_event_sqs_dlq_secret" {
  metadata {
    name      = "producer-event-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.producer_event_sqs_dlq.sqs_id
    sqs_queue_arn  = module.producer_event_sqs_dlq.sqs_arn
    sqs_queue_name = module.producer_event_sqs_dlq.sqs_name
  }
}
