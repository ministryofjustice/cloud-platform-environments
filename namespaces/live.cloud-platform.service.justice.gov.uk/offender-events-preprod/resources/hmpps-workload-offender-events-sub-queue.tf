module "hmpps_workload_offender_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_workload_offender_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_workload_offender_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 5
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_workload_offender_events_queue_policy" {
  queue_url = module.hmpps_workload_offender_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_workload_offender_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_workload_offender_events_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": ["${module.probation_offender_events.topic_arn}"]
                          }
                        }
        }
      ]
  }

EOF

}

module "hmpps_workload_offender_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_workload_offender_events_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_workload_offender_events_queue" {
  metadata {
    name      = "hmpps-workload-offender-events-sqs-instance-output"
    namespace = "hmpps-workload-preprod"
  }

  data = {
    access_key_id     = module.hmpps_workload_offender_events_queue.access_key_id
    secret_access_key = module.hmpps_workload_offender_events_queue.secret_access_key
    sqs_queue_url     = module.hmpps_workload_offender_events_queue.sqs_id
    sqs_queue_arn     = module.hmpps_workload_offender_events_queue.sqs_arn
    sqs_queue_name    = module.hmpps_workload_offender_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_workload_offender_events_dead_letter_queue" {
  metadata {
    name      = "hmpps-workload-offender-events-sqs-dl-instance-output"
    namespace = "hmpps-workload-preprod"
  }
  data = {
    access_key_id     = module.hmpps_workload_offender_events_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_workload_offender_events_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_workload_offender_events_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_workload_offender_events_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_workload_offender_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_workload_offender_events_subscription" {
  provider      = aws.london
  topic_arn     = module.probation_offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.hmpps_workload_offender_events_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"SENTENCE_CHANGED\",\"OFFENDER_DETAILS_CHANGED\"]}"
}

