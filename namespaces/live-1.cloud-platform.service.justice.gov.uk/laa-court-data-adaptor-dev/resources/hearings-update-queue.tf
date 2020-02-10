module "hearings_update_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment_name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = var.sqs_queue_name
  encrypt_sqs_kms           = var.encrypt_sqs_kms
  message_retention_seconds = var.message_retention_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hearings_update_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hearings_update_queue_policy" {
  queue_url = module.hearings_update_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hearings_update_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "PublishPolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hearings_update_queue.sqs_arn}",
          "Action": "sqs:SendMessage"
        },
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "902837325998"
              ]
          },
          "Resource": "${module.hearings_update_queue.sqs_arn}",
          "Action": "sqs:ReceiveMessage",
        }
      ]
  }
   EOF
}

module "hearings_update_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = var.sqs_queue_name_dl
  encrypt_sqs_kms        = var.encrypt_sqs_kms

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hearings_update_queue" {
  metadata {
    name      = "hearings-update-sqs-instance-output"
    namespace = "laa-court-data-adaptor-dev"
  }

  data = {
    access_key_id     = module.hearings_update_queue.access_key_id
    secret_access_key = module.hearings_update_queue.secret_access_key
    sqs_url           = module.hearings_update_queue.sqs_id
    sqs_arn           = module.hearings_update_queue.sqs_arn
    sqs_name          = module.hearings_update_queue.sqs_name
  }
}

resource "kubernetes_secret" "hearings_update_dead_letter_queue" {
  metadata {
    name      = "hearings-update-sqs-dl-instance-output"
    namespace = "laa-court-data-adaptor-dev"
  }

  data = {
    access_key_id     = module.hearings_update_dead_letter_queue.access_key_id
    secret_access_key = module.hearings_update_dead_letter_queue.secret_access_key
    sqs_url           = module.hearings_update_dead_letter_queue.sqs_id
    sqs_arn           = module.hearings_update_dead_letter_queue.sqs_arn
    sqs_name          = module.hearings_update_dead_letter_queue.sqs_name
  }
}

