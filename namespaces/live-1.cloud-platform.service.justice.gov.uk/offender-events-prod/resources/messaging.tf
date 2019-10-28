module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=3.0"

  team_name          = "${var.team_name}"
  topic_display_name = "offender-events"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "offender_events" {
  metadata {
    name      = "offender-events-topic"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.offender_events.access_key_id}"
    secret_access_key = "${module.offender_events.secret_access_key}"
    topic_arn         = "${module.offender_events.topic_arn}"
  }
}

resource "kubernetes_secret" "offender_case_notes" {
  metadata {
    name      = "offender-events-topic"
    namespace = "offender-case-notes-prod"
  }

  data {
    access_key_id     = "${module.offender_events.access_key_id}"
    secret_access_key = "${module.offender_events.secret_access_key}"
    topic_arn         = "${module.offender_events.topic_arn}"
  }
}

module "keyworker_api_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.4"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "keyworker_api_queue"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.keyworker_api_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = "aws.london"
  }
}

resource "aws_sqs_queue_policy" "keyworker_api_queue_policy" {
  queue_url = "${module.keyworker_api_queue.sqs_id}"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.keyworker_api_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.keyworker_api_queue.sqs_arn}",
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

module "keyworker_api_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.4"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "keyworker_api_queue_dl"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "keyworker_api_queue" {
  metadata {
    name      = "rp-sqs-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.keyworker_api_queue.access_key_id}"
    secret_access_key = "${module.keyworker_api_queue.secret_access_key}"
    sqs_rpc_url       = "${module.keyworker_api_queue.sqs_id}"
    sqs_rpc_arn       = "${module.keyworker_api_queue.sqs_arn}"
    sqs_rpc_name      = "${module.keyworker_api_queue.sqs_name}"
    sqs_rpc_dlq_url   = "${module.keyworker_api_queue.sqs_id}"
    sqs_rpc_dlq_arn   = "${module.keyworker_api_queue.sqs_arn}"
    sqs_rpc_dlq_name  = "${module.keyworker_api_queue.sqs_name}"
  }
}

resource "kubernetes_secret" "keyworker_api_dead_letter_queue" {
  metadata {
    name      = "rp-sqs-dl-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.keyworker_api_dead_letter_queue.access_key_id}"
    secret_access_key = "${module.keyworker_api_dead_letter_queue.secret_access_key}"
    sqs_rpc_url       = "${module.keyworker_api_dead_letter_queue.sqs_id}"
    sqs_rpc_arn       = "${module.keyworker_api_dead_letter_queue.sqs_arn}"
    sqs_rpc_name      = "${module.keyworker_api_dead_letter_queue.sqs_name}"
  }
}

resource "aws_sns_topic_subscription" "keyworker_api_subscription" {
  provider      = "aws.london"
  topic_arn     = "${module.offender_events.topic_arn}"
  protocol      = "sqs"
  endpoint      = "${module.keyworker_api_queue.sqs_arn}"
  filter_policy = "{\"eventType\":[\"EXTERNAL_MOVEMENT_RECORD-INSERTED\", \"BOOKING_NUMBER-CHANGED\"]}"
}
