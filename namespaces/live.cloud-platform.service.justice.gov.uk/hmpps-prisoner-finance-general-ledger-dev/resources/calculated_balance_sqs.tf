module "prisoner_finance_general_ledger_queue_for_calculated_balances" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"


  sqs_name                        = "gl-queue-for-calculated-balances"
  encrypt_sqs_kms                 = "true"
  fifo_queue                      = true
  delay_seconds                   = 0

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_arn
    maxReceiveCount     = 5
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name 
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_iam_policy" "gl_calculated_balances_sqs" {
  name        = "${var.namespace}-gl-calculated-balances-sqs"
  description = "Allow GL app to send/receive/delete messages on calculated balances queue"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSendReceiveCalculatedBalances",
        Effect = "Allow",
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:GetQueueUrl"
        ],
        Resource = module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_arn
      }
    ]
  })
}

module "prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "gl-queue-for-calculated-balances-dlq"
  encrypt_sqs_kms = "true"

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

resource "kubernetes_secret" "prisoner_finance_general_ledger_queue_for_calculated_balances" {
  metadata {
    name      = "prisoner-finance-general-ledger-queue-for-calculated-balances"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_id
    sqs_queue_arn  = module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_arn
    sqs_queue_name = module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue" {
  metadata {
    name      = "prisoner-finance-general-ledger-queue-for-calculated-balances-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_arn
    sqs_queue_name = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_name
  }
}
