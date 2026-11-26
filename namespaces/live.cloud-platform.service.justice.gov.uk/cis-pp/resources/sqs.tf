data "aws_s3_bucket" "bps_reconciliation" {
  bucket = "laa-sds-cis-staging"
}

module "bps_payment_reconciliation_queue" {
  #checkov:skip=CKV_TF_1:Cloud Platform modules use version tags not commit hashes
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name                   = "${var.namespace}-payment-reconciliation"
  encrypt_sqs_kms            = true
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 300

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "bps_payment_reconciliation_queue" {
  queue_url = module.bps_payment_reconciliation_queue.sqs_id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowReconciliationBucketNotifications"
        Effect    = "Allow"
        Principal = { Service = "s3.amazonaws.com" }
        Action    = "sqs:SendMessage"
        Resource  = module.bps_payment_reconciliation_queue.sqs_arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = data.aws_s3_bucket.bps_reconciliation.arn
          }
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
        }
      },
    ]
  })
}

data "aws_kms_alias" "bps_payment_reconciliation_queue" {
  # The SQS module does not export its KMS key ARN.
  name = "alias/${replace(module.bps_payment_reconciliation_queue.sqs_name, ".", "-")}"

  depends_on = [module.bps_payment_reconciliation_queue]
}

resource "kubernetes_secret" "bps_payment_reconciliation_sqs_output" {
  metadata {
    name      = "bps-payment-reconciliation-sqs-output"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.bps_payment_reconciliation_queue.sqs_id
    sqs_queue_arn  = module.bps_payment_reconciliation_queue.sqs_arn
    sqs_queue_name = module.bps_payment_reconciliation_queue.sqs_name
  }
}
