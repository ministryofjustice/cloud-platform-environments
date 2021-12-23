module "create_and_vary_a_licence_prison_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "create_and_vary_a_licence_prison_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_and_vary_a_licence_prison_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "create_and_vary_a_licence_probation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "create_and_vary_a_licence_probation_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.create_and_vary_a_licence_probation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

module "create_and_vary_a_licence_prison_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "create_and_vary_a_licence_prison_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

module "create_and_vary_a_licence_probation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.4"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "create_and_vary_a_licence_probation_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}


resource "aws_sqs_queue_policy" "create_and_vary_a_licence_prison_events_queue_policy" {
  queue_url = module.create_and_vary_a_licence_prison_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.create_and_vary_a_licence_prison_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.create_and_vary_a_licence_prison_events_queue.sqs_arn}",
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

resource "aws_sqs_queue_policy" "pathfinder_probation_offender_events_queue_policy" {
  queue_url = module.create_and_vary_a_licence_probation_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.create_and_vary_a_licence_probation_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.create_and_vary_a_licence_probation_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
            {
              "ArnEquals":
                {
                  "aws:SourceArn": "${module.probation_offender_events.topic_arn}"
                }
            }
        }
      ]
  }
   EOF
}

resource "aws_sns_topic_subscription" "create_and_vary_a_licence_probation_events_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.create_and_vary_a_licence_prison_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"ADDRESS-UPDATED\", \"BOOKING_NUMBER-CHANGED\", \"CONFIRMED_RELEASE_DATE-CHANGED\", \"DATA_COMPLIANCE_DELETE-OFFENDER\", \"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"IMPRISONMENT_STATUS-CHANGED\", \"OFFENDER-UPDATED\", \"OFFENDER_BOOKING-CHANGED\", \"OFFENDER_DETAILS-CHANGED\", \"OFFENDER_MOVEMENT-DISCHARGE\", \"OFFENDER_MOVEMENT-RECEPTION\", \"OFFENDER_PROFILE_DETAILS-UPDATED\", \"SENTENCE-DATES-CHANGED\", \"SENTENCE_CALCULATION_DATES-CHANGED\"]}"
}

resource "aws_sns_topic_subscription" "create_and_vary_a_licence_probation_events_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.create_and_vary_a_licence_probation_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"OFFENDER_CHANGED\"]}"
}
