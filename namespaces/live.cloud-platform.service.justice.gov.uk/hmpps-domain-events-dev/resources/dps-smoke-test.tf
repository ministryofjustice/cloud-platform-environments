
module "dps_smoketest_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "dps_smoketest_dev_hmpps_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 600
  namespace                 = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "dps_smoketest_queue_policy" {
  queue_url = module.dps_smoketest_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.dps_smoketest_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.dps_smoketest_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${module.hmpps-domain-events.topic_arn}"
                          }
                        }
        }
      ]
  }

EOF

}

resource "kubernetes_secret" "dps_smoketest_queue" {
  metadata {
    name      = "dps-smoketest-queue-secret"
    namespace = "dps-toolkit"
  }

  data = {
    access_key_id     = module.dps_smoketest_queue.access_key_id
    secret_access_key = module.dps_smoketest_queue.secret_access_key
    sqs_queue_url     = module.dps_smoketest_queue.sqs_id
    sqs_queue_arn     = module.dps_smoketest_queue.sqs_arn
    sqs_queue_name    = module.dps_smoketest_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "dps_smoketest_subscription" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.dps_smoketest_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.released\", \"prison-offender-events.prisoner.received\"]}"
}
