module "sqs_overnight" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_overnight_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120   # 2 minutes
  fifo_queue                 = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.sqs_overnight_dl.sqs_arn
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

resource "aws_sqs_queue_policy" "overnight_sqs_policy" {
  queue_url = module.sqs_overnight.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.sqs_overnight.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.sqs_overnight.sqs_arn}",
          "Action": [
            "SQS:SendMessage",
            "SQS:ReceiveMessage",
            "SQS:DeleteMessage",
            "SQS:GetQueueAttributes"
          ],
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.sync_participant_command.topic_arn}"
                }
              }
        }
      ]
  }
  EOF
}

module "sqs_overnight_dl" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_overnight_dlq"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 604800 # 7 days
  visibility_timeout_seconds = 120    # 2 minutes
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

resource "kubernetes_secret" "sqs_overnight" {
  metadata {
    name      = "sqs-overnight-output"
    namespace = var.namespace
  }

  data = {
    queue_id   = module.sqs_overnight.sqs_id
    queue_arn  = module.sqs_overnight.sqs_arn
    queue_name = module.sqs_overnight.sqs_name
  }
}

resource "kubernetes_secret" "sqs_overnight_dl" {
  metadata {
    name      = "sqs-overnight-dl-output"
    namespace = var.namespace
  }

  data = {
    queue_id   = module.sqs_overnight_dl.sqs_id
    queue_arn  = module.sqs_overnight_dl.sqs_arn
    queue_name = module.sqs_overnight_dl.sqs_name
  }
}
