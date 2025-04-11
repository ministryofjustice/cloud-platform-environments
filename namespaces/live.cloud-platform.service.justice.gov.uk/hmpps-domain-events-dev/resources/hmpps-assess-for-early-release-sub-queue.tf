module "afer_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1"

  # Queue configuration
  sqs_name                  = "afer_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.afer_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "afer_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.1"

  # Queue configuration
  sqs_name        = "afer_domain_events_queue_dl"
  encrypt_sqs_kms = "true"

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

resource "aws_sqs_queue_policy" "afer_domain_events_queue_policy" {
  queue_url = module.afer_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.afer_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.afer_domain_events_queue.sqs_arn}",
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

resource "aws_sns_topic_subscription" "afer_domain_events_subscription" {
  provider  = aws.london
  topic_arn = module.hmpps-domain-events.topic_arn
  protocol  = "sqs"
  endpoint  = module.afer_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.received",
      "prisoner-offender-search.prisoner.updated"
    ]
  })
}

resource "kubernetes_secret" "hmpps-assess-for-early-release_domain_events_queue" {
  metadata {
    name      = "hmpps-assess-for-early-release-domain-events-sqs-instance-output"
    namespace = "hmpps-assess-for-early-release-dev"
  }

  data = {
    sqs_id   = module.afer_domain_events_queue.sqs_id
    sqs_arn  = module.afer_domain_events_queue.sqs_arn
    sqs_name = module.afer_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps-assess-for-early-release_domain_events_dead_letter_queue" {
  metadata {
    name      = "hmpps-assess-for-early-release-domain-events-sqs-dl-instance-output"
    namespace = "hmpps-assess-for-early-release-dev"
  }

  data = {
    sqs_id   = module.afer_domain_events_dead_letter_queue.sqs_id
    sqs_arn  = module.afer_domain_events_dead_letter_queue.sqs_arn
    sqs_name = module.afer_domain_events_dead_letter_queue.sqs_name
  }
}
