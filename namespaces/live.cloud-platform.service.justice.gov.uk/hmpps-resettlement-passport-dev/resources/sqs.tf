module "case-note-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  sqs_name                  = "case-note-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.case-note-dlq.sqs_arn
    maxReceiveCount     = 3
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

data "aws_iam_policy_document" "sqs" {
  policy_id = "${module.case-note-queue.sqs_arn}/SQSDefaultPolicy"

  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    resources = [module.case-note-queue.sqs_arn]
    actions   = ["SQS:SendMessage",
                "sqs:ReceiveMessage"
                ]
  }
}

resource "aws_sqs_queue_policy" "case-note-queue-policy" {
  queue_url = module.case-note-queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs.json
}

module "case-note-dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  sqs_name        = "case-note-dlq"
  encrypt_sqs_kms = "true"

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "case-note-queue" {
  metadata {
    name      = "sqs-case-note-queue-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.case-note-queue.sqs_id
    sqs_queue_arn  = module.case-note-queue.sqs_arn
    sqs_queue_name = module.case-note-queue.sqs_name
  }
}

resource "kubernetes_secret" "case-note-queue-dlq" {
  metadata {
    name      = "sqs-case-note-queue-dlq-secret"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.case-note-dlq.sqs_id
    sqs_queue_arn  = module.case-note-dlq.sqs_arn
    sqs_queue_name = module.case-note-dlq.sqs_name
  }
}
