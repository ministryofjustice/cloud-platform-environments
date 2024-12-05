module "event_test_client_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.event_test_client_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

module "event_test_client_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "event_test_client_queue_dl"
  encrypt_sqs_kms = "true"

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

resource "aws_sqs_queue_policy" "event_test_client_queue_policy" {
  queue_url = module.event_test_client_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.event_test_client_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.event_test_client_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.hmpps-integration-events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF

  depends_on = [
    module.hmpps-integration-events
  ]
}

resource "aws_sns_topic_subscription" "event_test_client_subscription" {
  topic_arn = module.hmpps-integration-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.event_test_client_queue.sqs_arn

  depends_on = [
    module.hmpps-integration-events
  ]
}

resource "kubernetes_secret" "event_test_client_queue" {
  metadata {
    name      = "event-test-client-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.event_test_client_queue.sqs_id
    sqs_arn  = module.event_test_client_queue.sqs_arn
    sqs_name = module.event_test_client_queue.sqs_name
  }
}

resource "kubernetes_secret" "event_test_client_dead_letter_queue" {
  metadata {
    name      = "event-test-client-dl-queue"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.event_test_client_dead_letter_queue.sqs_id
    sqs_arn  = module.event_test_client_dead_letter_queue.sqs_arn
    sqs_name = module.event_test_client_dead_letter_queue.sqs_name
  }
}
