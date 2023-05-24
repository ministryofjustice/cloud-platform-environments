

module "hmpps_workload_prisoner_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name          = var.environment
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_workload_prisoner_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_workload_prisoner_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_workload_prisoner_queue_policy" {
  queue_url = module.hmpps_workload_prisoner_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_workload_prisoner_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_workload_prisoner_queue.sqs_arn}",
          "Action": "SQS:SendMessage",
          "Condition":
                      {
                        "ArnEquals":
                          {
                            "aws:SourceArn": "${data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value}"
                          }
                        }
        }
      ]
  }

EOF

}

module "hmpps_workload_prisoner_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.1"

  environment-name       = var.environment
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_workload_prisoner_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sns_topic_subscription" "hmpps_workload_prisoner_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_workload_prisoner_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "prison-offender-events.prisoner.released",
      "prison-offender-events.prisoner.received"
    ]
  })
}


resource "kubernetes_secret" "hmpps_workload_prisoner_queue_secret" {
  metadata {
    name      = "sqs-prisoner-events-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_workload_prisoner_queue.access_key_id
    secret_access_key = module.hmpps_workload_prisoner_queue.secret_access_key
    sqs_queue_url     = module.hmpps_workload_prisoner_queue.sqs_id
    sqs_queue_arn     = module.hmpps_workload_prisoner_queue.sqs_arn
    sqs_queue_name    = module.hmpps_workload_prisoner_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_workload_prisoner_queue_dead_letter_queue" {
  metadata {
    name      = "sqs-prisoner-events-dl-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_workload_prisoner_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_workload_prisoner_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_workload_prisoner_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_workload_prisoner_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_workload_prisoner_dead_letter_queue.sqs_name
  }
}

