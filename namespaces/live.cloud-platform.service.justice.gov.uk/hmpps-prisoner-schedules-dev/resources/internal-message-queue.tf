module "prisoner_schedules_internal_message_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  sqs_name                   = "internal_message_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.prisoner_schedules_internal_message_dlq.sqs_arn
    maxReceiveCount     = 5
  })

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-prisoner-schedules" # Hard coded as prefix in queue names
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "prisoner_schedules_internal_message_queue_policy" {
  queue_url = module.prisoner_schedules_internal_message_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.prisoner_schedules_internal_message_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement": [
       {
         "Effect": "Allow",
         "Principal": {"AWS": "*"},
         "Action": [
           "sqs:SendMessage",
           "sqs:ReceiveMessage",
           "sqs:DeleteMessage",
           "sqs:GetQueueAttributes"
         ],
         "Resource": "${module.prisoner_schedules_internal_message_queue.sqs_arn}"
       }
     ]
  }

EOF

}

module "prisoner_schedules_internal_message_dlq" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.3"

  # Queue configuration
  sqs_name        = "internal_message_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = "hmpps-prisoner-schedules" # Hard coded as prefix in queue names
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "prisoner_schedules_internal_message_queue" {
  metadata {
    name      = "internal-message-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_schedules_internal_message_queue.sqs_id
    sqs_arn  = module.prisoner_schedules_internal_message_queue.sqs_arn
    sqs_name = module.prisoner_schedules_internal_message_queue.sqs_name
  }
}

resource "kubernetes_secret" "prisoner_schedules_internal_message_dlq" {
  metadata {
    name      = "internal-message-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.prisoner_schedules_internal_message_dlq.sqs_id
    sqs_arn  = module.prisoner_schedules_internal_message_dlq.sqs_arn
    sqs_name = module.prisoner_schedules_internal_message_dlq.sqs_name
  }
}
