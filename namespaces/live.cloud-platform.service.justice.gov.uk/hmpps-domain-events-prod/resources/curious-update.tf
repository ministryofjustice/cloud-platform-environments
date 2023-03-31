
module "curious_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "curious_hmpps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.curious_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "curious_queue_policy" {
  queue_url = module.curious_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.curious_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.curious_queue.sqs_arn}",
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

module "curious_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment-name
  team_name              = "MegaNexus"
  infrastructure-support = var.infrastructure_support
  application            = "Curious Synchronisation Service"
  sqs_name               = "curious_hmpps_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "curious_queue" {
  metadata {
    name = "sqs-curious-secret"
    # injected here and then sent manually over to MegaNexus - an external supplier of the consuming service
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.curious_queue.access_key_id
    secret_access_key = module.curious_queue.secret_access_key
    sqs_queue_url     = module.curious_queue.sqs_id
    sqs_queue_arn     = module.curious_queue.sqs_arn
    sqs_queue_name    = module.curious_queue.sqs_name
  }
}

resource "kubernetes_secret" "curious_dlq" {
  metadata {
    name = "sqs-curious-dl-secret"
    # injected here and then sent manually over to MegaNexus - an external supplier of the consuming service
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.curious_dead_letter_queue.access_key_id
    secret_access_key = module.curious_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.curious_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.curious_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.curious_dead_letter_queue.sqs_name
  }
}


resource "aws_sns_topic_subscription" "curious_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.curious_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.received\"]}"
}

resource "aws_iam_access_key" "curious_queue_key_2023" {
  user = module.curious_queue.user_name
}

resource "aws_iam_access_key" "curious_dlq_key_2023" {
  user = module.curious_dead_letter_queue.user_name
}

resource "kubernetes_secret" "curious_queue_2023" {
  metadata {
    # injected here and then sent manually over to MegaNexus - an external supplier of the consuming service
    name      = "sqs-curious-secret-2023"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.curious_queue_key_2023.id
    secret_access_key = aws_iam_access_key.curious_queue_key_2023.secret
    sqs_queue_url     = module.curious_queue.sqs_id
    sqs_queue_arn     = module.curious_queue.sqs_arn
    sqs_queue_name    = module.curious_queue.sqs_name
  }
}

resource "kubernetes_secret" "curious_dlq_2023" {
  metadata {
    # injected here and then sent manually over to MegaNexus - an external supplier of the consuming service
    name      = "sqs-curious-dl-secret-2023"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.curious_dlq_key_2023.id
    secret_access_key = aws_iam_access_key.curious_dlq_key_2023.secret
    sqs_queue_url     = module.curious_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.curious_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.curious_dead_letter_queue.sqs_name
  }
}
