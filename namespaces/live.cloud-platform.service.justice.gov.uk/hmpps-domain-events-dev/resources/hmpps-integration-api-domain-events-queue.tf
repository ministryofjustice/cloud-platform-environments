module "hmpps_integration_api_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "hmpps_integration_api_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_integration_api_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "hmpps_integration_api_domain_events_queue_policy" {
  queue_url = module.hmpps_integration_api_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_integration_api_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_integration_api_domain_events_queue.sqs_arn}",
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

module "hmpps_integration_api_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "hmpps_integration_api_domain_events_dead_letter_queue"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = "Getting selected events from hmpps-domain-event-topic"
  is_production          = var.is_production
  team_name              = "Kainos" # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment-name
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}


resource "aws_iam_user" "hmpps-integration-api-domain-events-queue" {
  name = "hmpps-integration-api-domain-events-queue-user-dev"
  path = "/system/hmpps-integration-api-domain-events-queue-user/"
}

resource "aws_iam_access_key" "hmpps-integration-api-domain-events-queue-access" {
  user = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "hmpps-integration-api-domain-events-queue-policy" {
  policy_arn = module.hmpps_integration_api_domain_events_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "aws_iam_user_policy_attachment" "hmpps-integration-api-domain-events-dlq-policy" {
  policy_arn = module.hmpps_integration_api_domain_events_dead_letter_queue.irsa_policy_arn
  user       = aws_iam_user.user.name
}

resource "kubernetes_secret" "hmpps_integration_api_domain_events_queue" {
  metadata {
    name      = "hmpps-integration-api-domain-events-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.hmpps-integration-api-domain-events-queue-access.id
    secret_access_key = aws_iam_access_key.hmpps-integration-api-domain-events-queue-access.secret
    sqs_queue_url     = module.hmpps_integration_api_domain_events_queue.sqs_id
    sqs_queue_arn     = module.hmpps_integration_api_domain_events_queue.sqs_arn
    sqs_queue_name    = module.hmpps_integration_api_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_integration_api_domain_events_dead_letter_dlq" {
  metadata {
    name      = "sqs-hmpps-domain-events-dlq"
    namespace = var.namespace
  }

  data = {
    access_key_id     = aws_iam_access_key.hmpps-integration-api-domain-events-queue-access.id
    secret_access_key = aws_iam_access_key.hmpps-integration-api-domain-events-queue-access.secret
    sqs_queue_url     = module.hmpps_integration_api_domain_events_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_integration_api_domain_events_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_integration_api_domain_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_integration_api_domain_events_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps_integration_api_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offenders-events.prisoner.released"
    ]
  })
}