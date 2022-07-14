module "restricted_patients_sub_queue_for_domain_events" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure-support
  application               = var.application
  sqs_name                  = "rp_sub_queue_for_domain_events"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.restricted_patients_sub_queue_for_domain_events_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }
  EOF

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "restricted_patients_sub_queue_for_domain_events_queue_policy" {
  queue_url = module.restricted_patients_sub_queue_for_domain_events.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.restricted_patients_sub_queue_for_domain_events.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.restricted_patients_sub_queue_for_domain_events.sqs_arn}",
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

module "restricted_patients_sub_queue_for_domain_events_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.8"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure-support
  application            = var.application
  sqs_name               = "rp_sub_queue_for_domain_events_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "restricted_patients_sub_queue_for_domain_events" {
  metadata {
    name      = "restricted-patients-sub-queue-for-domain-events-instance-output"
    namespace = "hmpps-restricted-patients-api-dev"
  }

  data = {
    access_key_id     = module.restricted_patients_sub_queue_for_domain_events.access_key_id
    secret_access_key = module.restricted_patients_sub_queue_for_domain_events.secret_access_key
    sqs_wb_url        = module.restricted_patients_sub_queue_for_domain_events.sqs_id
    sqs_wb_arn        = module.restricted_patients_sub_queue_for_domain_events.sqs_arn
    sqs_wb_name       = module.restricted_patients_sub_queue_for_domain_events.sqs_name
  }
}

resource "kubernetes_secret" "restricted_patients_sub_queue_for_domain_events_dead_letter_queue" {
  metadata {
    name      = "restricted-patients-sub-queue-for-domain-events-dl-instance-output"
    namespace = "hmpps-restricted-patients-api-dev"
  }

  data = {
    access_key_id     = module.restricted_patients_sub_queue_for_domain_events_dead_letter_queue.access_key_id
    secret_access_key = module.restricted_patients_sub_queue_for_domain_events_dead_letter_queue.secret_access_key
    sqs_wb_url        = module.restricted_patients_sub_queue_for_domain_events_dead_letter_queue.sqs_id
    sqs_wb_arn        = module.restricted_patients_sub_queue_for_domain_events_dead_letter_queue.sqs_arn
    sqs_wb_name       = module.restricted_patients_sub_queue_for_domain_events_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "restricted_patients_sub_queue_for_domain_events_subscription_details" {
  provider      = aws.london
  topic_arn     = module.hmpps-domain-events.topic_arn
  protocol      = "sqs"
  endpoint      = module.restricted_patients_sub_queue_for_domain_events.sqs_arn
  filter_policy = "{\"eventType\":[\"prison-offender-events.prisoner.received\", \"restricted-patients.patient.removed\"]}"
}
