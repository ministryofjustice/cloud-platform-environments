

module "in_cell_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "in_cell_hmpps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.in_cell_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "in_cell_queue_policy" {
  queue_url = module.in_cell_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.in_cell_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.in_cell_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

module "in_cell_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment-name
  team_name              = "Kainos"
  infrastructure-support = var.infrastructure_support
  application            = "In-cell prisoner on boarding"
  sqs_name               = "in_cell_hmpps_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "in_cell_queue" {
  metadata {
    name      = "sqs-hmpps-domain-events"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.in_cell_queue.access_key_id
    secret_access_key = module.in_cell_queue.secret_access_key
    sqs_queue_url     = module.in_cell_queue.sqs_id
    sqs_queue_arn     = module.in_cell_queue.sqs_arn
    sqs_queue_name    = module.in_cell_queue.sqs_name
  }
}

resource "kubernetes_secret" "in_cell_dlq" {
  metadata {
    name      = "sqs-hmpps-domain-events-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.in_cell_dead_letter_queue.access_key_id
    secret_access_key = module.in_cell_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.in_cell_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.in_cell_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.in_cell_dead_letter_queue.sqs_name
  }
}


resource "aws_sns_topic_subscription" "in_cell_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.in_cell_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.released\", \"prison-offender-events.prisoner.received\"]}"
}


