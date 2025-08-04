module "rajinder_poc_sqs_queue" {
  source     = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"
  sqs_name   = "rajinder-poc-sqs-queue"
  fifo_queue = false
  /*   redrive_policy = jsonencode({
    deadLetterTargetArn = module.claim-criminal-injuries-application-dlq.sqs_arn
    maxReceiveCount     = 3
  }) */
  encrypt_sqs_kms = "false"

  # Tags
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

resource "aws_sqs_queue_policy" "rajinder_poc_sqs_queue" {
  queue_url = module.rajinder_poc_sqs_queue.sqs_id
  policy    = data.aws_iam_policy_document.sqs_send_only.json
}

#--Writes queue ARN to SSM, for consumption by other namespaces
resource "aws_ssm_parameter" "sqs_queue_arn" {
  type        = "String"
  name        = "/${var.namespace}/sqs-queue-arn"
  value       = module.rajinder_poc_sqs_queue.sqs_arn
  description = "SQS Queue ARN"
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    owner                  = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
    namespace              = var.namespace
  }
}