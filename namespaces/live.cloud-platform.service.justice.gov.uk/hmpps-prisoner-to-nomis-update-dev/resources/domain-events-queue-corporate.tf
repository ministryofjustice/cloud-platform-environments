module "hmpps_prisoner_to_nomis_corporate_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name                   = "hmpps_prisoner_to_nomis_corporate_queue"
  encrypt_sqs_kms            = "true"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 120

  redrive_policy = jsonencode({
    deadLetterTargetArn = module.hmpps_prisoner_to_nomis_corporate_dead_letter_queue.sqs_arn
    maxReceiveCount     = 3
  })

  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "aws_sqs_queue_policy" "hmpps_prisoner_to_nomis_corporate_queue_policy" {
  queue_url = module.hmpps_prisoner_to_nomis_corporate_queue.sqs_id

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Id": "${module.hmpps_prisoner_to_nomis_corporate_queue.sqs_arn}/SQSDefaultPolicy",
    "Statement":
      [
        {
          "Effect": "Allow",
          "Principal": {"AWS": "*"},
          "Resource": "${module.hmpps_prisoner_to_nomis_corporate_queue.sqs_arn}",
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

module "hmpps_prisoner_to_nomis_corporate_dead_letter_queue" {
  source = "github.com/ministryofjustice/cloud-platform-terraform-sqs?ref=5.1.0"

  # Queue configuration
  sqs_name        = "hmpps_prisoner_to_nomis_corporate_dlq"
  encrypt_sqs_kms = "true"


  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name # also used for naming the queue
  namespace              = var.namespace
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support

  providers = {
    aws = aws.london
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_corporate_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-corporate"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_corporate_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_corporate_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_corporate_queue.sqs_name
  }
}

resource "kubernetes_secret" "hmpps_prisoner_to_nomis_corporate_dead_letter_queue" {
  metadata {
    name      = "domain-events-sqs-nomis-update-corporate-dlq"
    namespace = var.namespace
  }

  data = {
    sqs_queue_url  = module.hmpps_prisoner_to_nomis_corporate_dead_letter_queue.sqs_id
    sqs_queue_arn  = module.hmpps_prisoner_to_nomis_corporate_dead_letter_queue.sqs_arn
    sqs_queue_name = module.hmpps_prisoner_to_nomis_corporate_dead_letter_queue.sqs_name
  }
}

resource "aws_sns_topic_subscription" "hmpps_prisoner_to_nomis_corporate_subscription" {
  provider  = aws.london
  topic_arn = data.aws_ssm_parameter.hmpps-domain-events-topic-arn.value
  protocol  = "sqs"
  endpoint  = module.hmpps_prisoner_to_nomis_corporate_queue.sqs_arn
  filter_policy_scope = "MessageBody"
  filter_policy = jsonencode({
    eventType = [
      "contacts-api.organisation.created",
      "contacts-api.organisation.updated",
      "contacts-api.organisation.deleted",
      "contacts-api.organisation-type.created",
      "contacts-api.organisation-type.updated",
      "contacts-api.organisation-type.deleted",
      "contacts-api.organisation-address.created",
      "contacts-api.organisation-address.updated",
      "contacts-api.organisation-address.deleted",
      "contacts-api.organisation-email.created",
      "contacts-api.organisation-email.updated",
      "contacts-api.organisation-email.deleted",
      "contacts-api.organisation-web-address.created",
      "contacts-api.organisation-web-address.updated",
      "contacts-api.organisation-web-address.deleted",
      "contacts-api.organisation-phone.created",
      "contacts-api.organisation-phone.updated",
      "contacts-api.organisation-phone.deleted",
      "contacts-api.organisation-address-phone.created",
      "contacts-api.organisation-address-phone.updated",
      "contacts-api.organisation-address-phone.deleted",
    ]
  })
}
