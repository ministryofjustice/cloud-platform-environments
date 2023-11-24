module "bvl_prison_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "bvl_prison_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.bvl_prison_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

module "bvl_prison_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "bvl_prison_events_queue_dl"
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

resource "aws_sqs_queue_policy" "bvl_prison_events_queue_policy" {
  queue_url = module.bvl_prison_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.bvl_prison_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.bvl_prison_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.offender_events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sns_topic_subscription" "bvl_prison_events_subscription" {
  provider  = aws.london
  topic_arn = module.offender_events.topic_arn
  protocol  = "sqs"
  endpoint  = module.bvl_prison_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received"
    ]
  })
}

resource "kubernetes_secret" "book_video_link_prison_events_queue" {
  metadata {
    name      = "book-video-link-prison-events-sqs-instance-output"
    namespace = "hmpps-book-video-link-dev"
  }

  data = {
    sqs_id   = module.bvl_prison_events_queue.sqs_id
    sqs_arn  = module.bvl_prison_events_queue.sqs_arn
    sqs_name = module.bvl_prison_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "book_video_link_prison_events_dead_letter_queue" {
  metadata {
    name      = "book-video-link-prison-events-sqs-dl-instance-output"
    namespace = "hmpps-book-video-link-dev"
  }

  data = {
    sqs_id   = module.bvl_prison_events_dead_letter_queue.sqs_id
    sqs_arn  = module.bvl_prison_events_dead_letter_queue.sqs_arn
    sqs_name = module.bvl_prison_events_dead_letter_queue.sqs_name
  }
}

