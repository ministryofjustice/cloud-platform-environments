module "case_note_poll_pusher_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.4"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "case_note_poll_pusher_queue"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.case_note_poll_pusher_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = "aws.london"
  }
}

resource "aws_sqs_queue_policy" "case_note_poll_pusher_queue_policy" {
  queue_url = "${module.case_note_poll_pusher_queue.sqs_id}"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.case_note_poll_pusher_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.case_note_poll_pusher_queue.sqs_arn}",
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

module "case_note_poll_pusher_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.4"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "case_note_poll_pusher_queue_dl"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "case_note_poll_pusher_queue" {
  metadata {
    name      = "cnpp-sqs-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.case_note_poll_pusher_queue.access_key_id}"
    secret_access_key = "${module.case_note_poll_pusher_queue.secret_access_key}"
    sqs_rpc_url       = "${module.case_note_poll_pusher_queue.sqs_id}"
    sqs_rpc_arn       = "${module.case_note_poll_pusher_queue.sqs_arn}"
    sqs_rpc_name      = "${module.case_note_poll_pusher_queue.sqs_name}"
    sqs_rpc_dlq_url   = "${module.case_note_poll_pusher_queue.sqs_id}"
    sqs_rpc_dlq_arn   = "${module.case_note_poll_pusher_queue.sqs_arn}"
    sqs_rpc_dlq_name  = "${module.case_note_poll_pusher_queue.sqs_name}"
  }
}

resource "kubernetes_secret" "case_note_poll_pusher_dead_letter_queue" {
  metadata {
    name      = "cnpp-sqs-dl-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.case_note_poll_pusher_dead_letter_queue.access_key_id}"
    secret_access_key = "${module.case_note_poll_pusher_dead_letter_queue.secret_access_key}"
    sqs_rpc_url       = "${module.case_note_poll_pusher_dead_letter_queue.sqs_id}"
    sqs_rpc_arn       = "${module.case_note_poll_pusher_dead_letter_queue.sqs_arn}"
    sqs_rpc_name      = "${module.case_note_poll_pusher_dead_letter_queue.sqs_name}"
  }
}

resource "aws_sns_topic_subscription" "case_note_poll_pusher_subscription" {
  provider      = "aws.london"
  topic_arn     = "${module.offender_events.topic_arn}"
  protocol      = "sqs"
  endpoint      = "${module.case_note_poll_pusher_queue.sqs_arn}"
  filter_policy = "{\"eventType\":[ \"PRISON-RELEASE\", \"TRANSFER+FROMTOL\", \"GEN-OBS\", {\"prefix\": \"OMIC\"}, {\"prefix\": \"OMIC_OPD\"}, {\"prefix\": \"ALERT\"}, {\"prefix\": \"KA\"} ] }"
}