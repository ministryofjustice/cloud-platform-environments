module "offender_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sns-topic?ref=3.0"

  team_name          = "${var.team_name}"
  topic_display_name = "offender-events"

  providers = {
    aws = "aws.london"
  }
}

module "offender_events_subscriber" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.2"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "offender_events_subscriber"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.offender_events_subscriber_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = "aws.london"
  }
}

resource "aws_sqs_queue_policy" "offender_events_subscriber_policy" {
  queue_url = "${module.offender_events_subscriber.sqs_id}"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.offender_events_subscriber.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.offender_events_subscriber.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.offender_events.topic_arn}"
                          }
                        }
                  }
        }
      ]
  }
   EOF
}

module "offender_events_subscriber_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.2"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "offender_events_subscriber_dl"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "offender_events" {
  metadata {
    name      = "offender-events-topic-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.offender_events.access_key_id}"
    secret_access_key = "${module.offender_events.secret_access_key}"
    topic_arn         = "${module.offender_events.topic_arn}"
  }
}

resource "kubernetes_secret" "offender_events_subscriber" {
  metadata {
    name      = "rp-sqs-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.offender_events_subscriber.access_key_id}"
    secret_access_key = "${module.offender_events_subscriber.secret_access_key}"
    sqs_rpc_url       = "${module.offender_events_subscriber.sqs_id}"
    sqs_rpc_arn       = "${module.offender_events_subscriber.sqs_arn}"
    sqs_rpc_name      = "${module.offender_events_subscriber.sqs_name}"
    sqs_rpc_dlq_url   = "${module.offender_events_subscriber.sqs_id}"
    sqs_rpc_dlq_arn   = "${module.offender_events_subscriber.sqs_arn}"
    sqs_rpc_dlq_name  = "${module.offender_events_subscriber.sqs_name}"
  }
}

resource "kubernetes_secret" "offender_events_subscriber_dead_letter_queue" {
  metadata {
    name      = "rp-sqs-dl-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.offender_events_subscriber_dead_letter_queue.access_key_id}"
    secret_access_key = "${module.offender_events_subscriber_dead_letter_queue.secret_access_key}"
    sqs_rpc_url       = "${module.offender_events_subscriber_dead_letter_queue.sqs_id}"
    sqs_rpc_arn       = "${module.offender_events_subscriber_dead_letter_queue.sqs_arn}"
    sqs_rpc_name      = "${module.offender_events_subscriber_dead_letter_queue.sqs_name}"
  }
}

resource "aws_sns_topic_subscription" "offender_events_subscription" {
  provider      = "aws.london"
  topic_arn     = "${module.offender_events.topic_arn}"
  protocol      = "sqs"
  endpoint      = "${module.offender_events_subscriber.sqs_arn}"
  filter_policy = "{\"eventType\": [\"NOMS_ID_CHANGED\"]}"
}
