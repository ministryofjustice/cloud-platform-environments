module "cfo_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "cfo_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cfo_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "cfo_queue_policy" {
  queue_url = module.cfo_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cfo_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cfo_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.offender_events.topic_arn}", "${module.probation_offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

module "cfo_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "cfo_queue_dl"
  encrypt_sqs_kms = "true"

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

resource "aws_iam_user" "user" {
  name = "cfo-queue-user-prod"
  path = "/system/cfo-queue-user/"
}

resource "aws_iam_access_key" "user" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "policy" {
  policy_arn = module.cfo_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "dlq-policy" {
  policy_arn = module.cfo_dead_letter_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "kubernetes_secret" "cfo_queue_credentials" {
  metadata {
    name      = "cfo-sqs-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
    sqs_cfo_url       = module.cfo_queue.sqs_id
    sqs_cfo_arn       = module.cfo_queue.sqs_arn
    sqs_cfo_name      = module.cfo_queue.sqs_name
  }
}

resource "kubernetes_secret" "cfo_dead_letter_queue_credentials" {
  metadata {
    name      = "cfo-sqs-dl-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.user.id
    secret_access_key = aws_iam_access_key.user.secret
    sqs_cfo_url       = module.cfo_dead_letter_queue.sqs_id
    sqs_cfo_arn       = module.cfo_dead_letter_queue.sqs_arn
    sqs_cfo_name      = module.cfo_dead_letter_queue.sqs_name
  }
}

resource "kubernetes_secret" "cfo_queue" {
  metadata {
    name      = "cfo-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_cfo_url  = module.cfo_queue.sqs_id
    sqs_cfo_arn  = module.cfo_queue.sqs_arn
    sqs_cfo_name = module.cfo_queue.sqs_name
  }
}

resource "kubernetes_secret" "cfo_dead_letter_queue" {
  metadata {
    name      = "cfo-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_cfo_url  = module.cfo_dead_letter_queue.sqs_id
    sqs_cfo_arn  = module.cfo_dead_letter_queue.sqs_arn
    sqs_cfo_name = module.cfo_dead_letter_queue.sqs_name
  }
}

# Subscriptions removed until CFO are ready to start consuming messages (so we don't falsely fire alerts)
resource "aws_sns_topic_subscription" "cfo_prison_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.cfo_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"OFFENDER_PROFILE_DETAILS-UPDATED\", \"ADDRESS-DELETED\", \"ADDRESS-UPDATED\", \"ALERT-DELETED\", \"ALERT-INSERTED\", \"ALERT-UPDATED\", \"BOOKING_NUMBER-CHANGED\", \"COURT_SENTENCE-CHANGED\", \"EXTERNAL_MOVEMENT_RECORD-DELETED\", \"EXTERNAL_MOVEMENT_RECORD-UPDATED\", \"IMPRISONMENT_STATUS-CHANGED\", \"OFFENDER_ADDRESS-DELETED\", \"OFFENDER_ADDRESS-UPDATED\", \"OFFENDER_ALIAS-CHANGED\", \"OFFENDER_BOOKING-CHANGED\", \"OFFENDER_BOOKING-INSERTED\", \"OFFENDER_BOOKING-REASSIGNED\", \"OFFENDER_DETAILS-CHANGED\", \"OFFENDER_IDENTIFIER-DELETED\", \"OFFENDER_IDENTIFIER-INSERTED\", \"OFFENDER_MOVEMENT-DISCHARGE\", \"OFFENDER_MOVEMENT-RECEPTION\", \"OFFENDER_PROFILE_DETAILS-INSERTED\", \"OFFENDER-UPDATED\", \"PERSON_ADDRESS-DELETED\", \"PERSON_ADDRESS-INSERTED\", \"PERSON_ADDRESS-UPDATED\", \"PHONE-DELETED\", \"PHONE-INSERTED\", \"PHONE-UPDATED\", \"RISK_SCORE-CHANGED\", \"RISK_SCORE-DELETED\", \"SENTENCE_CALCULATION_DATES-CHANGED\" ] }"
}

resource "aws_sns_topic_subscription" "cfo_probation_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.cfo_queue.sqs_arn
  filter_policy = "{\"eventType\":[ \"OFFENDER_CHANGED\"] }"
}
