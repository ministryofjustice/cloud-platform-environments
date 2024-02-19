module "in_cell_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "in_cell_hmpps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.in_cell_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "in_cell_hmpps_dlq"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = "In-cell prisoner on boarding"
  is_production          = var.is_production
  team_name              = "Kainos" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_iam_user" "in-cell-queue-user" {
  name = "in-cell-queue-user-preprod"
  path = "/system/in-cell-queue-user/"
}

resource "aws_iam_access_key" "in-cell-queue-access" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "in-cell-queue-policy" {
  policy_arn = module.in_cell_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "in-cell-dlq-policy" {
  policy_arn = module.in_cell_dead_letter_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "kubernetes_secret" "in_cell_queue" {
  metadata {
    name      = "sqs-hmpps-domain-events"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.in-cell-queue-access.id
    secret_access_key = aws_iam_access_key.in-cell-queue-access.secret
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
    access_key_id     = aws_iam_access_key.in-cell-queue-access.id
    secret_access_key = aws_iam_access_key.in-cell-queue-access.secret
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
