module "court-case-matcher-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name        = "court-case-matcher-queue"
  encrypt_sqs_kms = "true"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.court-case-matcher-dead-letter-queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "court-case-matcher-queue-policy" {
  queue_url = module.court-case-matcher-queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.court-case-matcher-queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.court-case-matcher-queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.court-case-events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

resource "aws_sns_topic_subscription" "court-case-matcher-topic-subscription" {
  provider  = aws.london
  topic_arn = module.court-case-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.court-case-matcher-queue.sqs_arn
}

module "court-case-matcher-dead-letter-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.12.0"

  # Queue configuration
  sqs_name                  = "court-case-matcher-dead-letter-queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  # Tags
  business_unit          = var.business_unit
  application            = "court-case-matcher"
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "court-case-matcher-queue-secret" {
  metadata {
    name      = "court-case-matcher-queue-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.court-case-matcher-queue.access_key_id
    secret_access_key = module.court-case-matcher-queue.secret_access_key
    sqs_id            = module.court-case-matcher-queue.sqs_id
    sqs_arn           = module.court-case-matcher-queue.sqs_arn
    user_name         = module.court-case-matcher-queue.user_name
    sqs_name          = module.court-case-matcher-queue.sqs_name
  }
}

resource "kubernetes_secret" "court-case-matcher-dead-letter-queue-secret" {
  metadata {
    name      = "court-case-matcher-queue-dead-letter-queue-credentials"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.court-case-matcher-dead-letter-queue.access_key_id
    secret_access_key = module.court-case-matcher-dead-letter-queue.secret_access_key
    sqs_id            = module.court-case-matcher-dead-letter-queue.sqs_id
    sqs_arn           = module.court-case-matcher-dead-letter-queue.sqs_arn
    user_name         = module.court-case-matcher-dead-letter-queue.user_name
    sqs_name          = module.court-case-matcher-dead-letter-queue.sqs_name
  }
}
