
  
module "curious_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "curious_hmpps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.curious_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "curious_hmpps_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = "Curious Synchronisation Service"
  is_production          = var.is_production
  team_name              = "MegaNexus" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

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
    sqs_queue_url  = module.curious_queue.sqs_id
    sqs_queue_arn  = module.curious_queue.sqs_arn
    sqs_queue_name = module.curious_queue.sqs_name
  }
}

resource "kubernetes_secret" "curious_dlq" {
  metadata {
    name = "sqs-curious-dl-secret"
    # injected here and then sent manually over to MegaNexus - an external supplier of the consuming service
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.curious_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.curious_dead_letter_queue.sqs_arn
    sqs_queue_name = module.curious_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "curious_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.curious_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.received\"]}"
}

resource "aws_iam_user" "user" {
  name = "curious-queue-user-dev"
  path = "/system/curious-queue-user/"
}

resource "aws_iam_access_key" "curious_queue_key_2023_september" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "policy" {
  policy_arn = module.curious_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "dlq-policy" {
  policy_arn = module.curious_dead_letter_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "kubernetes_secret" "curious_queue_2023_september" {
  metadata {
    # injected here and then sent manually over to MegaNexus - an external supplier of the consuming service
    name      = "sqs-curious-secret-2023-september"
    namespace = var.namespace
  }

  data = {
    access_key_id      = aws_iam_access_key.curious_queue_key_2023_september.id
    secret_access_key  = aws_iam_access_key.curious_queue_key_2023_september.secret
    sqs_queue_url      = module.curious_queue.sqs_id
    sqs_queue_arn      = module.curious_queue.sqs_arn
    sqs_queue_name     = module.curious_queue.sqs_name
    sqs_dlq_queue_url  = module.curious_dead_letter_queue.sqs_id
    sqs_dlq_queue_arn  = module.curious_dead_letter_queue.sqs_arn
    sqs_dlq_queue_name = module.curious_dead_letter_queue.sqs_name
  }
}
