module "restricted_patients_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.0"

  environment-name          = var.environment-name
  team_name                 = var.team_name
  infrastructure-support    = var.infrastructure_support
  application               = var.application
  sqs_name                  = "restricted_patients_queue"
  encrypt_sqs_kms           = "true"
  message_retention_seconds = 1209600
  namespace                 = var.namespace

  redrive_policy = <<EOF
  {
    "deadLetterTargetArn": "${module.restricted_patients_dead_letter_queue.sqs_arn}","maxReceiveCount": 3
  }

EOF


  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "restricted_patients_queue_policy" {
  queue_url = module.restricted_patients_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.restricted_patients_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.restricted_patients_queue.sqs_arn}",
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

module "restricted_patients_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=4.10.0"

  environment-name       = var.environment-name
  team_name              = var.team_name
  infrastructure-support = var.infrastructure_support
  application            = var.application
  sqs_name               = "restricted_patients_queue_dl"
  encrypt_sqs_kms        = "true"
  namespace              = var.namespace

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "restricted_patients_queue" {
  metadata {
    name      = "restricted-patients-queue-for-offender-events"
    namespace = "hmpps-restricted-patients-api-preprod"
  }

  data = {
    access_key_id     = module.restricted_patients_queue.access_key_id
    secret_access_key = module.restricted_patients_queue.secret_access_key
    sqs_queue_url     = module.restricted_patients_queue.sqs_id
    sqs_queue_arn     = module.restricted_patients_queue.sqs_arn
    sqs_queue_name    = module.restricted_patients_queue.sqs_name
  }
}

resource "kubernetes_secret" "restricted_patients_dead_letter_queue" {
  metadata {
    name      = "restricted-patients-dlq-for-offender-events"
    namespace = "hmpps-restricted-patients-api-preprod"
  }

  data = {
    access_key_id     = module.restricted_patients_dead_letter_queue.access_key_id
    secret_access_key = module.restricted_patients_dead_letter_queue.secret_access_key
    sqs_queue_url     = module.restricted_patients_dead_letter_queue.sqs_id
    sqs_queue_arn     = module.restricted_patients_dead_letter_queue.sqs_arn
    sqs_queue_name    = module.restricted_patients_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "restricted_patients_subscription" {
  provider      = aws.london
  topic_arn     = module.offender_events.topic_arn
  protocol      = "sqs"
  endpoint      = module.restricted_patients_queue.sqs_arn
  filter_policy = "{\"eventType\":[\"OFFENDER_MOVEMENT-RECEPTION\"]}"
}

