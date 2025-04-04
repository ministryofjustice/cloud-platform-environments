module "sqs_payment" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_payment_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120 # 2 minutes
  fifo_queue                 = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.sqs_payment_dl.sqs_arn
    maxReceiveCount     = 3
  })

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

resource "aws_sqs_queue_policy" "payment_sqs_policy" {
  queue_url = module.sqs_payment.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.sqs_payment.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "SQS:SendMessage",
          "SQS:ReceiveMessage", 
          "SQS:DeleteMessage",
          "SQS:GetQueueAttributes"
        ],
        "Resource": "${module.sqs_payment.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": [
              "${module.activity_approved_event.topic_arn}",
              "${module.participant_transitioned_event.topic_arn}",
              "${module.hub_induction_created_event.topic_arn}",
              "${module.pri_assigned_event.topic_arn}",
              "${module.pri_ttg_completed_event.topic_arn}",
              "${module.wing_induction_created_event.topic_arn}"
            ]
          }
        }
      }
    ]
  }
  EOF
}

module "sqs_payment_dl" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_payment_dead_letter_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 604800 # 7 days
  visibility_timeout_seconds = 120 # 2 minutes
  fifo_queue                 = "true"

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

resource "kubernetes_secret" "sqs_payment" {
  metadata {
    name      = "sqs-payment-output"
    namespace = var.namespace
  }

  data = {
    queue_id  = module.sqs_payment.sqs_id
    queue_arn  = module.sqs_payment.sqs_arn
    queue_name = module.sqs_payment.sqs_name
  }
}

resource "kubernetes_secret" "sqs_payment_dl" {
  metadata {
    name      = "sqs-payment-dl-output"
    namespace = var.namespace
  }

  data = {
    queue_id  = module.sqs_payment_dl.sqs_id
    queue_arn  = module.sqs_payment_dl.sqs_arn
    queue_name = module.sqs_payment_dl.sqs_name
  }
}
