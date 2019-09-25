module "risk_profiler_change" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.2"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "risk_profiler_change"

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.risk_profiler_change_dead_letter_queue.sqs_arn}","maxReceiveCount": 1
  }
  EOF

  providers = {
    aws = "aws.london"
  }
}

resource "aws_sqs_queue_policy" "risk_profiler_change_policy" {
  queue_url = "${module.risk_profiler_change.sqs_id}"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.risk_profiler_change.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.risk_profiler_change.sqs_arn}",
          "Action": "SQS:SendMessage"
        }
      ]
  }
   EOF
}

module "risk_profiler_change_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=3.2"

  environment-name       = "${var.environment-name}"
  team_name              = "${var.team_name}"
  infrastructure-support = "${var.infrastructure-support}"
  application            = "${var.application}"
  sqs_name               = "risk_profiler_change_dl"

  providers = {
    aws = "aws.london"
  }
}

resource "kubernetes_secret" "risk_profiler_change" {
  metadata {
    name      = "rp-sqs-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.risk_profiler_change.access_key_id}"
    secret_access_key = "${module.risk_profiler_change.secret_access_key}"
    sqs_rpc_url       = "${module.risk_profiler_change.sqs_id}"
    sqs_rpc_arn       = "${module.risk_profiler_change.sqs_arn}"
    sqs_rpc_name      = "${module.risk_profiler_change.sqs_name}"
    sqs_rpc_dlq_url   = "${module.risk_profiler_change_dead_letter_queue.sqs_id}"
    sqs_rpc_dlq_arn   = "${module.risk_profiler_change_dead_letter_queue.sqs_arn}"
    sqs_rpc_dlq_name  = "${module.risk_profiler_change_dead_letter_queue.sqs_name}"
  }
}

resource "kubernetes_secret" "risk_profiler_change_dead_letter_queue" {
  metadata {
    name      = "rp-sqs-dl-instance-output"
    namespace = "${var.namespace}"
  }

  data {
    access_key_id     = "${module.risk_profiler_change_dead_letter_queue.access_key_id}"
    secret_access_key = "${module.risk_profiler_change_dead_letter_queue.secret_access_key}"
    sqs_rpc_url       = "${module.risk_profiler_change_dead_letter_queue.sqs_id}"
    sqs_rpc_arn       = "${module.risk_profiler_change_dead_letter_queue.sqs_arn}"
    sqs_rpc_name      = "${module.risk_profiler_change_dead_letter_queue.sqs_name}"
  }
}
