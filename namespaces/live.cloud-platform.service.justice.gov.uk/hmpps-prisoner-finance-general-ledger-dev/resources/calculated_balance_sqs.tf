module "prisoner_finance_general_ledger_queue_for_calculated_balances" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"


  sqs_name                        = "prisoner_finance_general_ledger_queue_for_calculated_balances"
  encrypt_sqs_kms                 = "true"
  sqs_queue_subscriber_namespaces = []
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

resource "aws_sqs_queue_policy" "prisoner_finance_general_ledger_queue_for_calculated_balances_policy" {
  queue_url = module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.prisoner_finance_general_ledger_queue_for_calculated_balances.sqs_arn}",
          "Action": [
            "SQS:SendMessage",
            "SQS:ReceiveMessage"
          ],
          "Condition":
                        {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.calculated_balance_queue_topic_arn.value}"
                          }
                        }
        },
        
      ]
  }
   EOF
}

module "prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "prisoner_finance_general_ledger_queue_for_calculated_balances_dlq"
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
    name      = "prisoner_finance_general_ledger_queue_for_calculated_balances"
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
    name      = "prisoner_finance_general_ledger_queue_for_calculated_balances_dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_arn
    sqs_queue_name = module.prisoner_finance_general_ledger_queue_for_calculated_balances_dead_letter_queue.sqs_name
  }
}
