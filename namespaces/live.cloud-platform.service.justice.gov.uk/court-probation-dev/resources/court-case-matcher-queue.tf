module "court-case-matcher-queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = "court-case-matcher"
  sqs_name               = "court-case-matcher-queue"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.court-case-matcher-dead-letter-queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF


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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = "court-case-matcher"
  sqs_name                  = "court-case-matcher-dead-letter-queue"
  encrypt_sqs_kms           = "true"
  namespace                 = var.namespace
  message_retention_seconds = 1209600

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
