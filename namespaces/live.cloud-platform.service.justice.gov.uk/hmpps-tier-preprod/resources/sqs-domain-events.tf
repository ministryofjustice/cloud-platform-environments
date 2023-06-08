

module "hmpps_tier_domain_events_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "hmpps_tier_domain_events_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace
  delay_seconds             = 2
  receive_wait_time_seconds = 20

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.hmpps_tier_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_tier_domain_events_queue_policy" {
  queue_url = module.hmpps_tier_domain_events_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_tier_domain_events_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_tier_domain_events_queue.sqs_arn}",
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

module "hmpps_tier_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.11.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "hmpps_tier_domain_events_dlq"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "aws_sns_topic_subscription" "hmpps_tier_domain_events_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_tier_domain_events_queue.sqs_arn
  filter_policy = jsonencode({
    eventType = [
      "enforcement.breach.raised",
      "enforcement.breach.concluded",
      "enforcement.recall.raised",
      "enforcement.recall.concluded",
      "person.risk.registration.added",
      "person.risk.registration.ended"
    ]
  })
}


resource "kubernetes_secret" "hmpps_tier_domain_events_queue_secret" {
  metadata {
    name      = "sqs-domain-events-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_tier_domain_events_queue.access_key_id
    secret_access_key = module.hmpps_tier_domain_events_queue.secret_access_key
    sqs_queue_url     = module.hmpps_tier_domain_events_queue.sqs_id
    sqs_queue_arn     = module.hmpps_tier_domain_events_queue.sqs_arn
    sqs_queue_name    = module.hmpps_tier_domain_events_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_tier_domain_events_queue_secret_dead_letter_queue" {
  metadata {
    name      = "sqs-domain-events-dl-secret"
    namespace = var.namespace
  }

  data = {
    access_key_id     = module.hmpps_tier_domain_events_dead_letter_queue.access_key_id
    secret_access_key = module.hmpps_tier_domain_events_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.hmpps_tier_domain_events_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.hmpps_tier_domain_events_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.hmpps_tier_domain_events_dead_letter_queue.sqs_name
  }
}
