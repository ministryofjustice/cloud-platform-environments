module "offender_categorisation_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "offender_categorisation_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_categorisation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "offender_categorisation_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_categorisation_events_queue" {
  metadata {
    name      = "oc-events-sqs-instance-output"
    namespace = "offender-categorisation-prod"
  }

  data = {
    access_key_id     = module.offender_categorisation_events_queue.access_key_id
    secret_access_key = module.offender_categorisation_events_queue.secret_access_key
    sqs_oce_url       = module.offender_categorisation_events_queue.sqs_id
    sqs_oce_arn       = module.offender_categorisation_events_queue.sqs_arn
    sqs_oce_name      = module.offender_categorisation_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_categorisation_events_dead_letter_queue" {
  metadata {
    name      = "oc-events-sqs-dl-instance-output"
    namespace = "offender-categorisation-prod"
  }

  data = {
    access_key_id     = module.offender_categorisation_events_dead_letter_queue.access_key_id
    secret_access_key = module.offender_categorisation_events_dead_letter_queue.secret_access_key
    sqs_oce_url       = module.offender_categorisation_events_dead_letter_queue.sqs_id
    sqs_oce_arn       = module.offender_categorisation_events_dead_letter_queue.sqs_arn
    sqs_oce_name      = module.offender_categorisation_events_dead_letter_queue.sqs_name
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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "offender_categorisation_ui_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_categorisation_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

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
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.1"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "offender_categorisation_ui_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "offender_categorisation_ui_events_queue" {
  metadata {
    name      = "ocu-events-sqs-instance-output"
    namespace = "offender-categorisation-prod"
  }

  data = {
    access_key_id     = module.offender_categorisation_ui_events_queue.access_key_id
    secret_access_key = module.offender_categorisation_ui_events_queue.secret_access_key
    url               = module.offender_categorisation_ui_events_queue.sqs_id
    arn               = module.offender_categorisation_ui_events_queue.sqs_arn
    name              = module.offender_categorisation_ui_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "offender_categorisation_ui_events_dead_letter_queue" {
  metadata {
    name      = "ocu-events-sqs-dl-instance-output"
    namespace = "offender-categorisation-prod"
  }

  data = {
    access_key_id     = module.offender_categorisation_ui_events_dead_letter_queue.access_key_id
    secret_access_key = module.offender_categorisation_ui_events_dead_letter_queue.secret_access_key
    url               = module.offender_categorisation_ui_events_dead_letter_queue.sqs_id
    arn               = module.offender_categorisation_ui_events_dead_letter_queue.sqs_arn
    name              = module.offender_categorisation_ui_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "offender_categorisation_ui_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.offender_categorisation_ui_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"BOOKING_NUMBER-CHANGED\",\"DATA_COMPLIANCE_DELETE-OFFENDER\"]}"
}
