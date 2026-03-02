module "cvl_prison_events_queue" {
  
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name                  = "cvl_prison_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.cvl_prison_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "cvl_prison_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.2"

  # Queue configuration
  sqs_name        = "cvl_prison_events_queue_dl"
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

resource "aws_sqs_queue_policy" "cvl_prison_events_queue_policy" {
  queue_url = module.cvl_prison_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.cvl_prison_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.cvl_prison_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${data.aws_ssm_parameter.offender-events-topic-arn.value}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sns_topic_subscription" "cvl_prison_events_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.offender-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.cvl_prison_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "SENTENCE_DATES-CHANGED",
      "CONFIRMED_RELEASE_DATE-CHANGED"
    ]
  })
}

resource "kubernetes_secret" "cvl_prison_events_queue" {
  metadata {
    name      = "cvl-prison-events-sqs-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.cvl_prison_events_queue.sqs_id
    sqs_arn  = module.cvl_prison_events_queue.sqs_arn
    sqs_name = module.cvl_prison_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "cvl_prison_events_dead_letter_queue" {
  metadata {
    name      = "cvl-prison-events-sqs-dl-instance-output"
    namespace = var.namespace
  }

  data = {
    sqs_id   = module.cvl_prison_events_dead_letter_queue.sqs_id
    sqs_arn  = module.cvl_prison_events_dead_letter_queue.sqs_arn
    sqs_name = module.cvl_prison_events_dead_letter_queue.sqs_name
  }
}

