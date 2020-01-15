module "pathfinder_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "pathfinder_events_queue"
  encrypt_sqs_kms        = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.pathfinder_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "pathfinder_events_queue_policy" {
  queue_url = module.pathfinder_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.pathfinder_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.pathfinder_events_queue.sqs_arn}",
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

module "pathfinder_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "pathfinder_events_queue_dl"
  encrypt_sqs_kms        = "true"

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "pathfinder_events_queue" {
  metadata {
    name      = "pathfinder-events-sqs-instance-output"
    namespace = "pathfinder-preprod"
  }

  data = {
    access_key_id     = module.pathfinder_events_queue.access_key_id
    secret_access_key = module.pathfinder_events_queue.secret_access_key
    sqs_id            = module.pathfinder_events_queue.sqs_id
    sqs_arn           = module.pathfinder_events_queue.sqs_arn
    sqs_name          = module.pathfinder_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "pathfinder_events_dead_letter_queue" {
  metadata {
    name      = "pathfinder-events-sqs-dl-instance-output"
    namespace = "pathfinder-preprod"
  }

  data = {
    access_key_id     = module.pathfinder_events_dead_letter_queue.access_key_id
    secret_access_key = module.pathfinder_events_dead_letter_queue.secret_access_key
    sqs_id            = module.pathfinder_events_dead_letter_queue.sqs_id
    sqs_arn           = module.pathfinder_events_dead_letter_queue.sqs_arn
    sqs_name          = module.pathfinder_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "pathfinder_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.pathfinder_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"ALERT-INSERTED\", \"ALERT-UPDATED\"], \"code\":[\"XTACT\"]}"
}
