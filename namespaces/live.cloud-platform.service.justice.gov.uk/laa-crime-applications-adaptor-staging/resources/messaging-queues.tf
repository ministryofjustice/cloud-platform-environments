module "update_application_status_queue_m" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name           = var.environment_name
  team_name                  = var.team_name
  infrastructure-support     = var.infrastructure_support
  application                = var.application
  sqs_name                   = "update-application-status-queue-m"
  encrypt_sqs_kms            = var.encrypt_sqs_kms
  message_retention_seconds  = var.message_retention_seconds
  namespace                  = var.namespace
  visibility_timeout_seconds = var.visibility_timeout_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.update_application_status_queue_m_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}


resource "aws_sqs_queue_policy" "update_application_status_queue_m_policy" {
  queue_url = module.update_application_status_queue_m.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.update_application_status_queue_m.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "PublishPolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.update_application_status_queue_m.sqs_arn}",
          "Action": "sqs:SendMessage"
        }
      ]
  }
   EOF
}

module "update_application_status_queue_m_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "update-application-status-queue-dl-m"
  encrypt_sqs_kms        = var.encrypt_sqs_kms
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "update_application_status_queue_m" {
  metadata {
    name      = "caa-messaging-queues-output"
    namespace = var.namespace
  }

  data = {
    access_key_id                           = module.update_application_status_queue_m.access_key_id
    secret_access_key                       = module.update_application_status_queue_m.secret_access_key
    sqs_url_update_application_status       = module.update_application_status_queue_m.sqs_id
    sqs_arn_update_application_status       = module.update_application_status_queue_m.sqs_arn
    sqs_name_update_application_status      = module.update_application_status_queue_m.sqs_name
    sqs_url_d_update_application_status     = module.update_application_status_queue_m_dead_letter_queue.sqs_id
    sqs_arn_d_update_application_status     = module.update_application_status_queue_m_dead_letter_queue.sqs_arn
    sqs_name_d_update_application_status    = module.update_application_status_queue_m_dead_letter_queue.sqs_name
  }
}
