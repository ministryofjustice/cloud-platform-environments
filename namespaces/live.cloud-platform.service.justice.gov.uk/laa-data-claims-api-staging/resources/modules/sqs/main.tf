module "queue" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"
  sqs_name   = var.queue_name
  fifo_queue = var.fifo_queue
  redrive_policy = jsonencode({
    deadLetterTargetArn = module.dlq.sqs_arn
    maxReceiveCount     = var.dlq_max_receive_count
  })
  encrypt_sqs_kms = var.encrypted_queue

  # Tags
  business_unit              = var.business_unit
  application                = var.application
  is_production              = var.is_production
  team_name                  = var.team_name
  namespace                  = var.namespace
  environment_name           = var.environment
  infrastructure_support     = var.infrastructure_support
  visibility_timeout_seconds = var.visibility_timeout_seconds
}

module "dlq" {
  source          = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"
  sqs_name        = "${var.queue_name}-dlq"
  fifo_queue      = false
  encrypt_sqs_kms = var.encrypted_queue

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "sqs" {
  queue_url = module.queue.sqs_id
  policy    = data.aws_iam_policy_document.queue.json
}

resource "aws_sqs_queue_policy" "dlq" {
  queue_url = module.dlq.sqs_id
  policy    = data.aws_iam_policy_document.dlq.json
}
