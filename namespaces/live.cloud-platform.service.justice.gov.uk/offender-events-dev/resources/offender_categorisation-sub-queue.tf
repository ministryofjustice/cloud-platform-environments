module "offender_categorisation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "offender_categorisation_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_categorisation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "offender_categorisation_events_queue_policy" {
  queue_url = module.offender_categorisation_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.offender_categorisation_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.offender_categorisation_events_queue.sqs_arn}",
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

module "offender_categorisation_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "offender_categorisation_events_queue_dl"
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

resource "kubernetes_secret" "offender_categorisation_events_queue" {
  metadata {
    name      = "oc-events-sqs-instance-output"
    namespace = "offender-categorisation-dev"
  }

  data = {
    sqs_oce_url  = module.offender_categorisation_events_queue.sqs_id
    sqs_oce_arn  = module.offender_categorisation_events_queue.sqs_arn
    sqs_oce_name = module.offender_categorisation_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_categorisation_events_dead_letter_queue" {
  metadata {
    name      = "oc-events-sqs-dl-instance-output"
    namespace = "offender-categorisation-dev"
  }

  data = {
    sqs_oce_url  = module.offender_categorisation_events_dead_letter_queue.sqs_id
    sqs_oce_arn  = module.offender_categorisation_events_dead_letter_queue.sqs_arn
    sqs_oce_name = module.offender_categorisation_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "offender_categorisation_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.offender_categorisation_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"ALERT-INSERTED\", \"ALERT-UPDATED\", \"ALERT-DELETED\", \"INCIDENT-INSERTED\", \"INCIDENT-CHANGED-CASES\", \"INCIDENT-CHANGED-PARTIES\", \"INCIDENT-CHANGED-RESPONSES\", \"INCIDENT-CHANGED-REQUIREMENTS\"]}"
}

############################################################################################


module "offender_categorisation_ui_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name                  = "offender_categorisation_ui_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_categorisation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
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

resource "aws_sqs_queue_policy" "offender_categorisation_ui_events_queue_policy" {
  queue_url = module.offender_categorisation_ui_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.offender_categorisation_ui_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.offender_categorisation_ui_events_queue.sqs_arn}",
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

module "offender_categorisation_ui_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.0.0"

  # Queue configuration
  sqs_name        = "offender_categorisation_ui_events_queue_dl"
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

resource "kubernetes_secret" "offender_categorisation_ui_events_queue" {
  metadata {
    name      = "ocu-events-sqs-instance-output"
    namespace = "offender-categorisation-dev"
  }

  data = {
    url  = module.offender_categorisation_ui_events_queue.sqs_id
    arn  = module.offender_categorisation_ui_events_queue.sqs_arn
    name = module.offender_categorisation_ui_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_categorisation_ui_events_dead_letter_queue" {
  metadata {
    name      = "ocu-events-sqs-dl-instance-output"
    namespace = "offender-categorisation-dev"
  }

  data = {
    url  = module.offender_categorisation_ui_events_dead_letter_queue.sqs_id
    arn  = module.offender_categorisation_ui_events_dead_letter_queue.sqs_arn
    name = module.offender_categorisation_ui_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "offender_categorisation_ui_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.offender_categorisation_ui_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"EXTERNAL_MOVEMENT_RECORD-INSERTED\",\"BOOKING_NUMBER-CHANGED\",\"prisoner-offender-search.prisoner.released\"]}"
}
