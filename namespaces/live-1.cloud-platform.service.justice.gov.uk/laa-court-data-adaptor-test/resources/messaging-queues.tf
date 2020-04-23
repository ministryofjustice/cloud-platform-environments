module "create_link_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name          = var.environment_name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "create-link-queue"
  encrypt_sqs_kms           = var.encrypt_sqs_kms
  message_retention_seconds = var.message_retention_seconds

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_link_queue_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}


resource "aws_sqs_queue_policy" "create_link_queue_policy" {
  queue_url = module.create_link_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.create_link_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Sid": "PublishPolicy",
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.create_link_queue.sqs_arn}",
          "Action": "sqs:SendMessage"
        },
        {
          "Sid": "ConsumePolicy",
          "Effect": "Allow",
          "Principal": {
          "AWS": [
            "013163512034"
              ]
          },
          "Resource": "${module.create_link_queue.sqs_arn}",
          "Action": "sqs:ReceiveMessage"
        }
      ]
  }
   EOF
}


module "create_link_queue_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment_name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "create-link-queue-dl"
  existing_user_name     = module.create_link_queue.user_name
  encrypt_sqs_kms        = var.encrypt_sqs_kms

  providers = {
    aws = aws.london
  }
}



resource "kubernetes_secret" "create_link_queue" {
  metadata {
    name      = "ca-messaging-queues-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.create_link_queue.access_key_id
    secret_access_key = module.create_link_queue.secret_access_key
    sqs_url_link      = module.create_link_queue.sqs_id
    sqs_arn_link      = module.create_link_queue.sqs_arn
    sqs_name_link     = module.create_link_queue.sqs_name
    sqs_url_d_link    = module.create_link_queue_dead_letter_queue.sqs_id
    sqs_arn_d_link    = module.create_link_queue_dead_letter_queue.sqs_arn
    sqs_name_d_link   = module.create_link_queue_dead_letter_queue.sqs_name
  }
}
