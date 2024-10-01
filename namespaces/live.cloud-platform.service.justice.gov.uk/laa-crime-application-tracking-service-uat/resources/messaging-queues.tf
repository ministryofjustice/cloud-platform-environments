module "process_email_notifications_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                   = "process-email-notifications-queue"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.process_email_notifications_queue_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

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


resource "aws_sqs_queue_policy" "process_email_notifications_queue_policy" {
  queue_url = module.process_email_notifications_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.process_email_notifications_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "Allow_SNS_topic_to_Send_Message",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.process_email_notifications_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition": {
            "ArnLike": {
              "aws:SourceArn": "arn:aws:sns:eu-west-1:140455166311:ses_complaint_events_uat"
            }
          }
        }
      ]
  }
   EOF
}

module "process_email_notifications_queue_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "process-email-notifications-queue-dl"
  encrypt_sqs_kms = var.encrypt_sqs_kms

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

resource "kubernetes_secret" "process_email_notifications_queue" {
  metadata {
    name      = "ats-messaging-queues-output"
    namespace = var.namespace
  }

  data = {
    sqs_url_process_email_notifications    = module.process_email_notifications_queue.sqs_id
    sqs_arn_process_email_notifications    = module.process_email_notifications_queue.sqs_arn
    sqs_name_process_email_notifications   = module.process_email_notifications_queue.sqs_name
    sqs_url_d_process_email_notifications  = module.process_email_notifications_queue_dead_letter_queue.sqs_id
    sqs_arn_d_process_email_notifications  = module.process_email_notifications_queue_dead_letter_queue.sqs_arn
    sqs_name_d_process_email_notifications = module.process_email_notifications_queue_dead_letter_queue.sqs_name
  }
}
