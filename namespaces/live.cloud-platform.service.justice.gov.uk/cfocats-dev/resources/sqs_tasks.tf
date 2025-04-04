module "sqs_tasks" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_tasks_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 43200 # 12 hours
  visibility_timeout_seconds = 120 # 2 minutes
  fifo_queue                 = "true"

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.sqs_tasks_dl.sqs_arn
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

resource "aws_sqs_queue_policy" "tasks_sqs_policy" {
  queue_url = module.sqs_tasks.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.sqs_tasks.sqs_arn}/SQSDefaultPolicy",
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
        "Resource": "${module.sqs_tasks.sqs_arn}",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": [
              "${module.objectivetask_completed_event.topic_arn}",
              "${module.participant_transitioned_event.topic_arn}"
            ]
          }
        }
      }
    ]
  }
  EOF
}

module "sqs_tasks_dl" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0" # use the latest release

  # Queue configuration
  sqs_name                   = "${var.namespace}_tasks_dlq"
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

resource "kubernetes_secret" "sqs_tasks" {
  metadata {
    name      = "sqs-tasks-output"
    namespace = var.namespace
  }

  data = {
    queue_id  = module.sqs_tasks.sqs_id
    queue_arn  = module.sqs_tasks.sqs_arn
    queue_name = module.sqs_tasks.sqs_name
  }
}

resource "kubernetes_secret" "sqs_tasks_dl" {
  metadata {
    name      = "sqs-tasks-dl-output"
    namespace = var.namespace
  }

  data = {
    queue_id  = module.sqs_tasks_dl.sqs_id
    queue_arn  = module.sqs_tasks_dl.sqs_arn
    queue_name = module.sqs_tasks_dl.sqs_name
  }
}
